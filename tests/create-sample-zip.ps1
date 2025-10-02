# tests/create-sample-zip.ps1

param (
    [Parameter(Mandatory)]
    [string]$OutputPath
)

# Create a dummy ZIP file for testing purposes
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = $OutputPath
$dummyFile = Join-Path -Path (Split-Path $zipPath) -ChildPath "dummy.txt"
Set-Content -Path $dummyFile -Value "This is a test file."
[System.IO.Compression.ZipFile]::CreateFromDirectory((Split-Path $zipPath), $zipPath)
