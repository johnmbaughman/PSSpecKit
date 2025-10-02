# Helper to run Pester v5 without legacy-parameter adaptation.
# If Pester v5 is not available, offer to install it into the CurrentUser scope (opt-in).
param(
	[switch]$AutoInstall  # If set, install Pester v5 automatically into CurrentUser scope when missing
)

function Test-PesterV5Available {
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

if (-not (Test-PesterV5Available)) {
	Write-Information 'Pester v5 is not available in your session.' -InformationAction Continue
	if ($AutoInstall) {
		Write-Information 'Installing Pester v5 to CurrentUser scope...' -InformationAction Continue
		try {
			Install-Module -Name Pester -MinimumVersion 5.0.0 -Scope CurrentUser -Force -AcceptLicense
		} catch {
			Write-Error "Failed to install Pester: $_"
			exit 1
		}
	} else {
		Write-Information "Run this to install Pester v5 for your user:" -InformationAction Continue
		Write-Information "  pwsh -Command `"Install-Module Pester -MinimumVersion 5.0.0 -Scope CurrentUser -Force -AcceptLicense`"" -InformationAction Continue
		Write-Information 'Or re-run this helper with -AutoInstall to install automatically.' -InformationAction Continue
		exit 2
	}
}

Import-Module Pester -MinimumVersion 5.0.0 -Force
Write-Information "Loaded Pester: $((Get-Module Pester).Version)" -InformationAction Continue

$r = Pester\Invoke-Pester -Path .\tests -PassThru
Write-Information "FailedCount=$($r.FailedCount)" -InformationAction Continue
if ($r.FailedCount -gt 0) { exit 1 } else { exit 0 }
