<#
.SYNOPSIS
Download and extract Spec Kit templates from the GitHub spec-kit releases.

.DESCRIPTION
This script finds the latest spec-kit release matching an agent and shell type,
downloads the corresponding ZIP asset (pattern: spec-kit-template-[agent]-[ps|sh]-v[version].zip),
validates the ZIP, and extracts files into the target directory.

.PARAMETER Agent
Agent name to select (optional). If omitted the script will auto-select a sensible default.
.PARAMETER Shell
Shell type: ps (PowerShell) or sh (POSIX shell). Default: ps
.PARAMETER Version
Release tag (e.g., v1.2.3) or 'latest' (default). When provided, the script will attempt that tag.
.PARAMETER Retry
Number of retries for network operations (default: 3)
.PARAMETER Force
Overwrite existing files when extracting.
.PARAMETER Path
Target extraction directory (default: current working directory)
.PARAMETER Interactive
If set and multiple candidate agents exist, prompt the user.

.EXITCODES
This script returns explicit numeric exit codes when executed directly. Code values:

- 0 : Success (templates extracted)
- 1 : Generic/fatal error
- 2 : Network error (download failures)
- 3 : Validation error (downloaded ZIP failed validation)
- 4 : Extraction error

.EXAMPLE
pwsh tools\spec-kit-downloader.ps1
pwsh tools\spec-kit-downloader.ps1 -Agent octo -Shell ps -Path .\templates -Force
#>

param(
    [string]$Agent,
    [ValidateSet('ps','sh')][string]$Shell = 'ps',
    [string]$Version = 'latest',
    [int]$Retry = 3,
    [switch]$Force,
    [string]$Path = (Get-Location).Path,
    [switch]$SaveZip,
    [switch]$Interactive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Script-scoped variable to capture exception details for error handling
$script:LastException = $null

# Exit code constants
$EXIT_SUCCESS = 0
$EXIT_GENERIC_ERROR = 1
$EXIT_NETWORK_ERROR = 2
$EXIT_VALIDATION_ERROR = 3
$EXIT_EXTRACTION_ERROR = 4

function Write-Info { param([string]$Message) Write-Information $Message -Tags Info }
# Use Write-Verbose for non-actionable notices so tests don't treat them as warnings.
function Write-Warn { param([string]$Message) Write-Verbose $Message }
function Write-Err { param([string]$Message) Write-Information $Message -Tags Error }

function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$Retries = 3
    )
    $attempt = 0
    while ($true) {
        try {
            return & $ScriptBlock
        } catch {
            $attempt++
            if ($attempt -ge $Retries) { throw }
            $delay = [math]::Pow(2, $attempt)
            Write-Warn "Attempt $attempt failed. Retrying in ${delay}s..."
            Start-Sleep -Seconds $delay
        }
    }
}

function Get-GitHubApiHeader {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    $headers = @{}
    if ($env:GITHUB_TOKEN) { $headers['Authorization'] = "token $($env:GITHUB_TOKEN)" }
    $headers['User-Agent'] = 'spec-kit-downloader'
    return $headers
}

function Get-LatestRelease {
    param([string]$Owner = 'github', [string]$Repo = 'spec-kit')
    $url = "https://api.github.com/repos/$Owner/$Repo/releases"
    $headers = Get-GitHubApiHeader
    $releases = Invoke-WithRetry -ScriptBlock { Invoke-RestMethod -Uri $url -Headers $headers -UseBasicParsing } -Retries $Retry
    if (-not $releases) { throw 'No releases found' }
    # Sort by semantic version if possible, fallback to published_at
    try {
        $sorted = $releases | Sort-Object { [Version]($_.tag_name.TrimStart('v')) } -Descending
    } catch {
        $sorted = $releases | Sort-Object published_at -Descending
    }
    return $sorted[0]
}

function Find-ReleaseAsset {
    param(
        $Release,
        [string]$Agent,
        [string]$Shell
    )
    $pattern = "spec-kit-template-{0}-{1}-v" -f ($Agent -replace '[^a-zA-Z0-9_-]',''), $Shell
    # Try find asset containing pattern
    foreach ($asset in $Release.assets) {
        if ($asset.name -like "*{0}*.zip" -f $pattern) {
            return $asset
        }
    }
    return $null
}

function Save-ReleaseAsset {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] $Asset,
        [string]$OutPath
    )
    $headers = Get-GitHubApiHeader
    if (-not $OutPath) {
        # Create a dedicated temp work directory for this download and keep the zip there
        $workDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
        New-Item -Path $workDir -ItemType Directory -Force | Out-Null
        $OutPath = Join-Path -Path $workDir -ChildPath $Asset.name
    }
    $url = $Asset.browser_download_url
    Write-Info "Downloading $($Asset.name) from $url to $OutPath"
    # Ensure the parent directory exists when OutPath is provided
    $parent = Split-Path -Path $OutPath -Parent
    if ($parent -and -not (Test-Path $parent)) { New-Item -Path $parent -ItemType Directory | Out-Null }
    Invoke-WithRetry -ScriptBlock { Invoke-WebRequest -Uri $url -Headers $headers -OutFile $OutPath -UseBasicParsing } -Retries $Retry
    return $OutPath
}

function Test-ZipArchive {
    param([string]$ZipPath)
    try {
        [System.IO.Compression.ZipFile]::OpenRead($ZipPath).Dispose()
        return $true
    } catch {
        Write-Err "ZIP validation failed: $_"
        return $false
    }
}

function Expand-SafeArchive {
    param([string]$ZipPath, [string]$TargetPath, [switch]$Force)
    # Extract into a temporary extraction directory located next to the zip when possible.
    # This keeps the downloaded zip in the parent work directory and allows us to remove only the extraction temp.
    $zipParent = Split-Path -Path $ZipPath -Parent
    if (-not $zipParent) { $zipParent = [System.IO.Path]::GetTempPath() }
    $tempExtract = Join-Path -Path $zipParent -ChildPath ([System.Guid]::NewGuid().ToString())
    New-Item -Path $tempExtract -ItemType Directory | Out-Null
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $tempExtract)
        # Move files from temp to target
        Get-ChildItem -Path $tempExtract -Recurse | ForEach-Object {
            $rel = $_.FullName.Substring($tempExtract.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
            $dest = Join-Path $TargetPath $rel
            if ($_.PSIsContainer) {
                if (-not (Test-Path $dest)) { New-Item -Path $dest -ItemType Directory | Out-Null }
            } else {
                $destDir = Split-Path -Path $dest -Parent
                if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory | Out-Null }
                if ((Test-Path $dest) -and (-not $Force)) {
                    Write-Warn "Skipping existing file: $dest"
                } else {
                    Move-Item -Path $_.FullName -Destination $dest -Force:$true
                }
            }
        }
        return $true
    } catch {
        Write-Err "Extraction failed: $_"
        return $false
    } finally {
        # Remove only the extraction temp directory. Do NOT remove the zip or its parent work directory.
        if (Test-Path $tempExtract) { Remove-Item -Path $tempExtract -Recurse -Force }
    }
}

function Install-SpecKitTemplate {
    param(
        [string]$Agent,
        [ValidateSet('ps','sh')][string]$Shell = 'ps',
        [string]$Version = 'latest',
        [int]$Retry = 3,
        [switch]$Force,
        [string]$Path = (Get-Location).Path,
        [switch]$SaveZip,
        [switch]$Interactive
    )

    try {
    Write-Info "Starting spec-kit downloader"

        $owner = 'github'
        $repo = 'spec-kit'

        # Determine release
        if ($Version -ne 'latest') {
            Write-Info "Looking up release $Version"
            $url = "https://api.github.com/repos/$owner/$repo/releases/tags/$Version"
            $headers = Get-GitHubApiHeader
            $release = Invoke-WithRetry -ScriptBlock { Invoke-RestMethod -Uri $url -Headers $headers -UseBasicParsing } -Retries $Retry
        } else {
            Write-Info "Fetching latest release metadata"
            $release = Get-LatestRelease -Owner $owner -Repo $repo
        }

    if (-not $release) { throw [System.Exception] 'Release not found' }

        # Agent auto-selection
        if (-not $Agent) {
            # Try to infer agent from release body or assets (simplified heuristic)
            $candidates = @()
            foreach ($a in $release.assets) {
                if ($a.name -match 'spec-kit-template-([^-]+)-') { $candidates += $matches[1] }
            }
            $candidates = @($candidates | Select-Object -Unique)
            if ($candidates.Count -eq 0) {
                        if ($Interactive -and -not $env:CI) {
                            $inputAgent = Read-Host 'No agent candidates found. Enter agent name (or press Enter to use "default")'
                            if ($inputAgent) { $Agent = $inputAgent } else { $Agent = 'default' }
                        } else {
                            Write-Warn 'No agent candidates found in release; defaulting to "default"'
                            $Agent = 'default'
                        }
            } elseif ($candidates.Count -eq 1) {
                        if ($Interactive -and -not $env:CI) {
                            $confirm = Read-Host "Found single candidate '$($candidates[0])'. Use this agent? (Y/n)"
                            if ($confirm -and $confirm -match '^[nN]') {
                                $alt = Read-Host 'Enter agent name'
                                if ($alt) { $Agent = $alt } else { $Agent = $candidates[0] }
                            } else {
                                $Agent = $candidates[0]
                            }
                            Write-Info "Agent selected: $Agent"
                        } else {
                            $Agent = $candidates[0]
                            Write-Info "Auto-selected agent: $Agent"
                        }
            } else {
                        if ($Interactive -and -not $env:CI) {
                            Write-Info "Multiple agents found: $($candidates -join ', '); interactive selection enabled"
                            $i = 0
                            foreach ($c in $candidates) { Write-Information "[$i] $c" -InformationAction Continue; $i++ }
                            $choice = Read-Host 'Select an agent index'
                            $Agent = $candidates[([int]$choice)]
                        } else {
                            # pick the first candidate as 'sensible' default
                            $Agent = $candidates[0]
                            Write-Info "Auto-selected agent (first candidate): $Agent"
                        }
            }
        }

        $asset = Find-ReleaseAsset -Release $release -Agent $Agent -Shell $Shell
    if (-not $asset) { throw [System.Exception] "No matching asset found for agent=$Agent shell=$Shell" }

        # Ensure target path exists before saving if requested
        if ($SaveZip -and -not (Test-Path $Path)) { New-Item -Path $Path -ItemType Directory | Out-Null }

        if ($SaveZip) {
            $outZip = Save-ReleaseAsset -Asset $asset -OutPath (Join-Path -Path $Path -ChildPath $asset.name)
        } else {
            $outZip = Save-ReleaseAsset -Asset $asset
        }

        if (-not (Test-ZipArchive -ZipPath $outZip)) { throw [System.FormatException] 'Downloaded archive failed validation' }

        if (-not (Test-Path $Path)) { New-Item -Path $Path -ItemType Directory | Out-Null }

    if (-not (Expand-SafeArchive -ZipPath $outZip -TargetPath $Path -Force:$Force)) { throw [System.IO.IOException] 'Extraction failed' }

        Write-Info "Success: templates extracted to $Path"
        return $Path
    } catch {
        # Log error and store exception for callers. Return $false so unit tests that call the function
        # directly can assert on boolean failure without dealing with thrown exceptions.
        Write-Err "ERROR: $_"
        $script:LastException = $_
        Write-Error -Message "Failed to install spec-kit template: $_" -ErrorAction Continue
        return $false
    }
}

# Only invoke main flow when the script is executed directly (not dot-sourced for tests)
if ($MyInvocation.InvocationName -ne '.') {
    # If executed directly and no Agent provided, prefer interactive selection unless running in CI
    if (-not $Agent -and -not $env:CI) { $Interactive = $true }
    $result = Install-SpecKitTemplate -Agent $Agent -Shell $Shell -Version $Version -Retry $Retry -Force:$Force -Path $Path -SaveZip:$SaveZip -Interactive:$Interactive
    if ($result) {
        Write-Output $result
        exit $EXIT_SUCCESS
    } else {
        # If the function returned $false, check the exception recorded in the script-scoped variable.
        $ex = $script:LastException
        if ($ex -is [System.Net.WebException]) {
            Write-Err "Network error: $ex"
            exit $EXIT_NETWORK_ERROR
        } elseif ($ex -is [System.FormatException]) {
            Write-Err "Validation error: $ex"
            exit $EXIT_VALIDATION_ERROR
        } elseif ($ex -is [System.IO.IOException]) {
            Write-Err "Extraction error: $ex"
            exit $EXIT_EXTRACTION_ERROR
        } else {
            Write-Err "Unknown/fatal error: $ex"
            exit $EXIT_GENERIC_ERROR
        }
    }
}
