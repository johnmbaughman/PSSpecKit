function Get-GitHubApiHeader {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    $headers = @{}
    if ($env:GITHUB_TOKEN) { $headers['Authorization'] = "token $($env:GITHUB_TOKEN)" }
    $headers['User-Agent'] = 'spec-kit-downloader'
    return $headers
}
