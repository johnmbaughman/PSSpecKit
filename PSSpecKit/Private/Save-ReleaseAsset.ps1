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
