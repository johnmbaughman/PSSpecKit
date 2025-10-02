function Install-SpecKitTemplate {
    <#
    .SYNOPSIS
    Download and extract Spec Kit templates from the GitHub spec-kit releases.

    .DESCRIPTION
    This function finds the latest spec-kit release matching an agent and shell type,
    downloads the corresponding ZIP asset (pattern: spec-kit-template-[agent]-[ps|sh]-v[version].zip),
    validates the ZIP, and extracts files into the target directory.

    .PARAMETER Agent
    Agent name to select (optional). If omitted the function will auto-select a sensible default.

    .PARAMETER Shell
    Shell type: ps (PowerShell) or sh (POSIX shell). Default: ps

    .PARAMETER Version
    Release tag (e.g., v1.2.3) or 'latest' (default). When provided, the function will attempt that tag.

    .PARAMETER Retry
    Number of retries for network operations (default: 3)

    .PARAMETER Force
    Overwrite existing files when extracting.

    .PARAMETER Path
    Target extraction directory (default: current working directory)

    .PARAMETER SaveZip
    Save the downloaded ZIP file in the target directory.

    .PARAMETER Interactive
    If set and multiple candidate agents exist, prompt the user.

    .EXAMPLE
    Install-SpecKitTemplate
    Downloads and extracts the latest spec-kit template to the current directory.

    .EXAMPLE
    Install-SpecKitTemplate -Agent octo -Shell ps -Path .\templates -Force
    Downloads the octo agent PowerShell template to the templates directory, overwriting existing files.

    .OUTPUTS
    System.String
    Returns the path where templates were extracted, or $false on failure.
    #>
    [CmdletBinding()]
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
                    foreach ($c in $candidates) { Write-Host "[$i] $c"; $i++ }
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
        # Log and record the exception for callers. Return $false so unit tests that call the function
        # directly can assert on boolean failure without dealing with thrown exceptions.
        Write-Err "ERROR: $_"
        $global:SPEC_KIT_DOWNLOADER_EXCEPTION = $_
        return $false
    }
}
