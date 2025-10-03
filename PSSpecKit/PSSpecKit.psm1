Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import private functions
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$Private = @(Get-ChildItem -Path "$PrivateDir\*.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $Private) {
    try {
        . $import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Import public functions
$PublicDir = Join-Path $PSScriptRoot 'Public'
$Public = @(Get-ChildItem -Path "$PublicDir\*.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $Public) {
    try {
        . $import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions and private functions for testing
# Private functions are marked as internal and should not be used directly by end users
$AllFunctions = @($Public.BaseName) + @($Private.BaseName)
if ($AllFunctions) {
    Export-ModuleMember -Function $AllFunctions
}
