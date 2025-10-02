# Idempotent helper to create tests/sample.zip with a single hello.txt file
param()

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$zipPath = Join-Path $scriptDir 'sample.zip'
$tempDir = Join-Path $scriptDir 'sample-tmp'

if (Test-Path $zipPath) {
    # If the zip already exists and contains hello.txt, do nothing
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
        $entries = [System.IO.Compression.ZipFile]::OpenRead($zipPath).Entries
        if ($entries.Name -contains 'hello.txt') { return $zipPath }
    } catch {
        # Fall through and recreate the zip
    }
}

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -Path $tempDir -ItemType Directory | Out-Null

$hello = Join-Path $tempDir 'hello.txt'
Set-Content -Path $hello -Value 'hello from sample.zip'

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)

Remove-Item $tempDir -Recurse -Force

Write-Output $zipPath
