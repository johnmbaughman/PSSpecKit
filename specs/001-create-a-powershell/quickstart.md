# Quickstart: Spec Kit Downloader

## Examples

Default (auto-select agent, PowerShell templates to current directory):

pwsh tools\Install-SpecKitTemplate.ps1

Example 1 — Basic run (auto-select agent)

```powershell
# Extracts templates for the auto-selected agent into the current directory
pwsh tools\Install-SpecKitTemplate.ps1
```

Example 2 — Specify agent and save the zip into the target path

```powershell
# Downloads the asset and saves the zip inside .\templates, then extracts there
pwsh tools\Install-SpecKitTemplate.ps1 -Agent myagent -Shell ps -Path .\templates -SaveZip -Force
```

Example 3 — Use an explicit release tag (reproducible)

```powershell
# Uses tag v1.2.3 from the spec-kit releases
pwsh tools\Install-SpecKitTemplate.ps1 -Version v1.2.3 -Path .\templates -Force
```

Specify agent and target path:

pwsh tools\Install-SpecKitTemplate.ps1 -Agent myagent -Shell ps -Path ./templates

Force overwrite existing files:

pwsh tools\Install-SpecKitTemplate.ps1 -Force

Use an explicit version tag:

pwsh tools\Install-SpecKitTemplate.ps1 -Version v1.2.3

Using GITHUB_TOKEN for higher rate limits (Windows PowerShell example):

$env:GITHUB_TOKEN = 'ghp_...'
pwsh tools\Install-SpecKitTemplate.ps1

Exit codes

The script emits explicit exit codes when executed directly. Example values:

- 0 : Success (templates extracted)
- 1 : Generic/fatal error
- 2 : Network error (download failures)
- 3 : Validation error (downloaded ZIP failed validation)
- 4 : Extraction error

Capture extraction path and exit code in PowerShell:

```powershell
$path = pwsh -NoProfile -File tools\Install-SpecKitTemplate.ps1 -Agent myagent -SaveZip -Force
$code = $LASTEXITCODE
Write-Host "Extraction path: $path; Exit code: $code"
```

Smoke test steps (manual verification)

1. Create a fresh temp folder and cd into it:

```powershell
$td = Join-Path $env:TEMP "speckit-smoke-$(Get-Random)"; New-Item -Path $td -ItemType Directory | Out-Null; Set-Location $td
```

2. Run the downloader (auto agent):

```powershell
pwsh ..\..\tools\Install-SpecKitTemplate.ps1 -Force
```

3. Verify that templates were extracted and check exit code:

```powershell
Get-ChildItem -Recurse
Write-Host "Exit code: $LASTEXITCODE"
```

4. If you want to run integration tests locally (dry-run):

```powershell
	pwsh -NoProfile -Command "Import-Module Pester -RequiredVersion 5.0.0 -Force; $r = Pester\Invoke-Pester -Path .\tests\integration -PassThru; if ($r.FailedCount -gt 0) { exit 1 }"
```
