# Helper to run Pester v5 without legacy-parameter adaptation.
# If Pester v5 is not available, offer to install it into the CurrentUser scope (opt-in).
param(
	[switch]$AutoInstall  # If set, install Pester v5 automatically into CurrentUser scope when missing
)

function Ensure-PesterV5 {
	try {
		$m = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
		if ($m -and $m.Version -ge [Version]'5.0.0') {
			return $true
		}
		return $false
	} catch {
		return $false
	}
}

if (-not (Ensure-PesterV5)) {
	Write-Host 'Pester v5 is not available in your session.'
	if ($AutoInstall) {
		Write-Host 'Installing Pester v5 to CurrentUser scope...'
		try {
			Install-Module -Name Pester -MinimumVersion 5.0.0 -Scope CurrentUser -Force -AcceptLicense
		} catch {
			Write-Error "Failed to install Pester: $_"
			exit 1
		}
	} else {
		Write-Host "Run this to install Pester v5 for your user:"
		Write-Host "  pwsh -Command \"Install-Module Pester -MinimumVersion 5.0.0 -Scope CurrentUser -Force -AcceptLicense\""
		Write-Host 'Or re-run this helper with -AutoInstall to install automatically.'
		exit 2
	}
}

Import-Module Pester -MinimumVersion 5.0.0 -Force
Write-Host "Loaded Pester: $((Get-Module Pester).Version)"

$r = Pester\Invoke-Pester -Path .\tests -PassThru
Write-Host "FailedCount=$($r.FailedCount)"
if ($r.FailedCount -gt 0) { exit 1 } else { exit 0 }
