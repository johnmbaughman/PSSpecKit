function Write-Info {
    param([string]$Message)
    Write-Information $Message -Tags Info
}
