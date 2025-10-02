Import-Module Pester

Describe 'Integration: spec-kit-downloader end-to-end (dry-run with sample zip)' {

    It 'extracts files from a provided sample zip by mocking network download' {
        # Use PSScriptRoot to reliably locate the helper script regardless of test runner cwd
        $testRoot = $PSScriptRoot
        $sampleZipScript = Join-Path $testRoot '..\create-sample-zip.ps1'
        $sampleZipScript = (Resolve-Path -Path $sampleZipScript).Path

        # Create sample.zip next to this test
        & pwsh -NoProfile -File $sampleZipScript
        $sampleZip = Join-Path (Split-Path -Parent $sampleZipScript) 'sample.zip'

        # Prepare a temp extraction directory
        $extractDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
        New-Item -Path $extractDir -ItemType Directory | Out-Null

    # Dot-source the main script so functions can be mocked
    . "$(Resolve-Path (Join-Path $PSScriptRoot '..\..\tools\Install-SpecKitTemplate.ps1'))"

    # Mock Save-ReleaseAsset to return the local sample zip path instead of downloading
        Mock -CommandName Save-ReleaseAsset -MockWith { param($Asset,$OutPath) return $sampleZip }

        # Mock Find-ReleaseAsset to return a fake asset object
        $fakeAsset = [pscustomobject]@{ name = 'spec-kit-template-sample-ps-v0.0.0.zip'; browser_download_url = 'file://local/sample.zip' }
        Mock -CommandName Find-ReleaseAsset -MockWith { param($Release,$Agent,$Shell) return $fakeAsset }

        # Run the installer function directly with mocks in place
        $result = Install-SpecKitTemplate -Agent 'sample' -Shell 'ps' -Path $extractDir -SaveZip -Force -Retry 1

        # Assert that result is the extraction path and that the hello.txt exists
        $result | Should -Not -BeNullOrEmpty
        $extractedHello = Join-Path $extractDir 'hello.txt'
        (Test-Path $extractedHello) | Should -BeTrue

        # Clean up
        if (Test-Path $extractDir) { Remove-Item -Path $extractDir -Recurse -Force }
        if (Test-Path $sampleZip) { Remove-Item -Path $sampleZip -Force }
    }
}
