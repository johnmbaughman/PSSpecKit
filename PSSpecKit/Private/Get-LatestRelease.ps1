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
