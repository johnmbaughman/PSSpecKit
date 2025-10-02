# Debug helper to reproduce failing interactive single-candidate test
Set-StrictMode -Version Latest
. $PSScriptRoot\Install-SpecKitTemplate.ps1
# Define fake release and asset
$asset = [pscustomobject]@{ name = 'spec-kit-template-myagent-ps-v1.0.0.zip'; browser_download_url = 'http://example.com/asset.zip' }
$fakeRelease = [pscustomobject]@{ assets = @($asset) }
# Mocks
function Get-LatestRelease { return $fakeRelease }
function Read-Host { param($p) return '' }
function Find-ReleaseAsset { param($Release,$Agent,$Shell) return $asset }
function Save-ReleaseAsset { param($Asset,$OutPath) return (Join-Path ([System.IO.Path]::GetTempPath()) $Asset.name) }
function Test-ZipArchive { param($ZipPath) return $true }
function Expand-SafeArchive { param($ZipPath,$TargetPath,$Force) return $true }
# Run
$tmp = Join-Path $PSScriptRoot '..\tests\tmp2' | Resolve-Path -Relative -ErrorAction SilentlyContinue
$tmp = Join-Path $PSScriptRoot 'tmp2'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
$res = Install-SpecKitTemplate -Agent $null -Shell 'ps' -Version 'latest' -Retry 1 -Force -Path $tmp -SaveZip:$true -Interactive
Write-Host "RESULT: $res"
Write-Host "GLOBAL EX: $global:SPEC_KIT_DOWNLOADER_EXCEPTION"
if ($global:SPEC_KIT_DOWNLOADER_EXCEPTION) { $global:SPEC_KIT_DOWNLOADER_EXCEPTION | Format-List * -Force }
