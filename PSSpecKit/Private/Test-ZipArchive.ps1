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
