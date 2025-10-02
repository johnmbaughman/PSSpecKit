$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$zip = Join-Path $root 'sample.zip'
$tempDir = Join-Path $root 'sample_tmp'
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -Path $tempDir -ItemType Directory | Out-Null
Set-Content -Path (Join-Path $tempDir 'hello.txt') -Value 'hello world'
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path $zip) { Remove-Item $zip -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zip)
Remove-Item $tempDir -Recurse -Force
Write-Output "Created $zip"
