function Write-Err {
    param([string]$Message)
    Write-Information $Message -Tags Error
}
