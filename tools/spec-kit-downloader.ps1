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
    [switch]$Interactive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $time = (Get-Date).ToString('o')
    Write-Output "[$time] [$Level] $Message"
}

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
            Write-Log "Attempt $attempt failed. Retrying in ${delay}s..." WARN
            Start-Sleep -Seconds $delay
        }
    }
}

function Get-GitHubApiHeaders {
    $headers = @{}
    if ($env:GITHUB_TOKEN) {
        $headers['Authorization'] = "token $($env:GITHUB_TOKEN)"
    }
    $headers['User-Agent'] = 'spec-kit-downloader'
    return $headers
}

function Get-LatestReleaseTag {
    param([string]$Owner = 'github', [string]$Repo = 'spec-kit')
    $url = "https://api.github.com/repos/$Owner/$Repo/releases"
    $headers = Get-GitHubApiHeaders
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

function Download-Asset {
    param($Asset, [string]$OutPath)
    $headers = Get-GitHubApiHeaders
    $url = $Asset.browser_download_url
    Write-Log "Downloading $($Asset.name) from $url"
    Invoke-WithRetry -ScriptBlock { Invoke-WebRequest -Uri $url -Headers $headers -OutFile $OutPath -UseBasicParsing } -Retries $Retry
}

function Validate-Zip {
    param([string]$ZipPath)
    try {
        [System.IO.Compression.ZipFile]::OpenRead($ZipPath).Dispose()
        return $true
    } catch {
        Write-Log "ZIP validation failed: $_" ERROR
        return $false
    }
}

function Safe-Extract {
    param([string]$ZipPath, [string]$TargetPath, [switch]$Force)
    $temp = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
    New-Item -Path $temp -ItemType Directory | Out-Null
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $temp)
        # Move files from temp to target
        Get-ChildItem -Path $temp -Recurse | ForEach-Object {
            $rel = $_.FullName.Substring($temp.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
            $dest = Join-Path $TargetPath $rel
            if ($_.PSIsContainer) {
                if (-not (Test-Path $dest)) { New-Item -Path $dest -ItemType Directory | Out-Null }
            } else {
                $destDir = Split-Path -Path $dest -Parent
                if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory | Out-Null }
                if ((Test-Path $dest) -and (-not $Force)) {
                    Write-Log "Skipping existing file: $dest" WARN
                } else {
                    Move-Item -Path $_.FullName -Destination $dest -Force:$true
                }
            }
        }
        return $true
    } catch {
        Write-Log "Extraction failed: $_" ERROR
        return $false
    } finally {
        if (Test-Path $temp) { Remove-Item -Path $temp -Recurse -Force }
    }
}

# Main
try {
    Write-Log "Starting spec-kit downloader"

    $owner = 'github'
    $repo = 'spec-kit'

    # Determine release
    if ($Version -ne 'latest') {
        Write-Log "Looking up release $Version"
        $url = "https://api.github.com/repos/$owner/$repo/releases/tags/$Version"
        $headers = Get-GitHubApiHeaders
        $release = Invoke-WithRetry -ScriptBlock { Invoke-RestMethod -Uri $url -Headers $headers -UseBasicParsing } -Retries $Retry
    } else {
        Write-Log "Fetching latest release metadata"
        $release = Get-LatestReleaseTag -Owner $owner -Repo $repo
    }

    if (-not $release) { throw 'Release not found' }

    # Agent auto-selection
    if (-not $Agent) {
        # Try to infer agent from release body or assets (simplified heuristic)
        $candidates = @()
        foreach ($a in $release.assets) {
            if ($a.name -match 'spec-kit-template-([^-]+)-') { $candidates += $matches[1] }
        }
        $candidates = $candidates | Select-Object -Unique
        if ($candidates.Count -eq 0) {
            Write-Log 'No agent candidates found in release; defaulting to "default"' WARN
            $Agent = 'default'
        } elseif ($candidates.Count -eq 1) {
            $Agent = $candidates[0]
            Write-Log "Auto-selected agent: $Agent"
        } else {
            if ($Interactive) {
                Write-Log "Multiple agents found: $($candidates -join ', '); interactive selection enabled"
                $i = 0
                foreach ($c in $candidates) { Write-Output "[$i] $c"; $i++ }
                $choice = Read-Host 'Select an agent index'
                $Agent = $candidates[([int]$choice)]
            } else {
                # pick the first candidate as 'sensible' default
                $Agent = $candidates[0]
                Write-Log "Auto-selected agent (first candidate): $Agent"
            }
        }
    }

    $asset = Find-ReleaseAsset -Release $release -Agent $Agent -Shell $Shell
    if (-not $asset) { throw "No matching asset found for agent=$Agent shell=$Shell" }

    $outZip = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath $asset.name
    Download-Asset -Asset $asset -OutPath $outZip

    if (-not (Validate-Zip -ZipPath $outZip)) { throw 'Downloaded archive failed validation' }

    if (-not (Test-Path $Path)) { New-Item -Path $Path -ItemType Directory | Out-Null }

    if (-not (Safe-Extract -ZipPath $outZip -TargetPath $Path -Force:$Force)) { throw 'Extraction failed' }

    Write-Log "Success: templates extracted to $Path"
    exit 0
} catch {
    Write-Log "ERROR: $_" ERROR
    exit 1
}
