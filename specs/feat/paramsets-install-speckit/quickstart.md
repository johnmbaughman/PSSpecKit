# Quickstart – Install-SpecKitTemplate Parameter Sets

## Prerequisites
- PowerShell 7.x (`pwsh`) installed and on PATH.
- Repository cloned with submodule/module dependencies restored.
- Pester v5 available (CI workflow will install if missing).

## Interactive Workflow
1. From the repo root run:
   ```powershell
   pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 -Interactive
   ```
2. Respond to prompts (press **Enter** to accept defaults; each accepted default is echoed).  
   - Agent → Shell (`ps`/`sh`) → Version (`latest` default) → Path (defaults to current directory).  
3. If existing files are detected, choose from `Yes`, `No`, `Yes to all`, `No to all`.  
4. Review the final summary confirmation and select **Yes** to proceed.  
5. On completion, verify exit code 0 and inspect the target directory for generated assets.

## Noninteractive Automation
Run the script with explicit parameters for CI or scripted scenarios:
```powershell
pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 `
    -Agent copilot -Shell ps -Version latest `
    -Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY `
    -Force -SaveZip -Retry 3
```
- Exits with code 0 on success.  
- Returns code 3 if validation fails or incompatible parameters are supplied.  
- Returns code 2 immediately when `-Interactive` is used in a non-TTY environment.

## Validation Checklist
- ✅ Pester suites pass:
  ```powershell
  pwsh -NoProfile tools/run-pester-v5.ps1
  ```
- ✅ PSScriptAnalyzer report clean for `tools/` and `PSSpecKit/`.
- ✅ Interactive run confirms overwrites and honours defaults.
- ✅ Noninteractive run respects exit codes and writes assets to the specified path.
- ✅ CI workflow (`.github/workflows/pester-and-lint.yml`) succeeds after updates.
