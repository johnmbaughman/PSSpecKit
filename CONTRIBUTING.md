# Contributing — test environment guidance

This project uses Pester v5 for unit and integration tests. If you run into the Pester "Legacy parameter set" warning, it means an older Pester module (v3) may be present on your system and PowerShell is resolving the invocation in compatibility mode.

Recommended: install Pester v5 into your CurrentUser scope:

```powershell
# Install Pester v5 for your user
pwsh -Command "Install-Module Pester -MinimumVersion 5.0.0 -Scope CurrentUser -Force -AcceptLicense"
```

You can run the provided helper which will detect and optionally install Pester v5 for you:

```powershell
# Run helper which prompts to install when missing
pwsh -NoProfile -File tools\run-pester-v5.ps1 -AutoInstall
```

If you prefer not to use the helper, run tests like this (recommended pattern):

```powershell
# Import Pester v5 explicitly and run tests, exiting non-zero on failures
pwsh -NoProfile -Command "Import-Module Pester -MinimumVersion 5.0.0 -Force; $r = Pester\Invoke-Pester -Path .\tests -PassThru; if ($r.FailedCount -gt 0) { exit 1 }"
```

Thanks for contributing! Please ensure tests pass locally before opening a PR. CI also installs Pester v5 so PR runs will use the correct version.