Describe 'Install-SpecKitTemplate interactive flows' {
    BeforeAll {
    # Import the module
        Import-Module "$PSScriptRoot\..\PSSpecKit\PSSpecKit.psd1" -Force
    }

    It 'prompts and accepts typed agent when no candidates found' {
        # Mock a release with no assets
        $fakeRelease = [pscustomobject]@{ assets = @() }
        Mock -CommandName Get-LatestRelease -ModuleName PSSpecKit -MockWith { return $fakeRelease }

        # Simulate user typing 'custom-agent' when prompted
        Mock -CommandName Read-Host -MockWith { return 'custom-agent' }

    Install-SpecKitTemplate -Agent $null -Shell 'ps' -Version 'latest' -Retry 1 -Force:$false -Path (Join-Path $PSScriptRoot 'tmp') -SaveZip:$false -Interactive | Out-Null
    # When no assets exist and user supplies custom-agent, Find-ReleaseAsset will be called with that name; the function will then throw later
    $global:SPEC_KIT_DOWNLOADER_EXCEPTION | Should -Not -BeNullOrEmpty
    }

    It 'confirms single candidate and accepts default when user presses Enter' {
        # Create a fake release with one matching asset
        $asset = [pscustomobject]@{ name = 'spec-kit-template-myagent-ps-v1.0.0.zip'; browser_download_url = 'http://example.com/asset.zip' }
        $fakeRelease = [pscustomobject]@{ assets = @($asset) }
        Mock -CommandName Get-LatestRelease -ModuleName PSSpecKit -MockWith { return $fakeRelease }

        # Mock Read-Host to simulate pressing Enter (empty input)
        Mock -CommandName Read-Host -MockWith { return '' }

        # Also mock Save-ReleaseAsset and Expand-SafeArchive to avoid network and disk operations
    Mock -CommandName Find-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Release,$Agent,$Shell) return $asset }
    Mock -CommandName Save-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Asset,$OutPath) return (Join-Path ([System.IO.Path]::GetTempPath()) $Asset.name) }
        Mock -CommandName Test-ZipArchive -ModuleName PSSpecKit -MockWith { return $true }
        Mock -CommandName Expand-SafeArchive -ModuleName PSSpecKit -MockWith { return $true }

        $tmp = Join-Path $PSScriptRoot 'tmp2'
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        $res = Install-SpecKitTemplate -Agent $null -Shell 'ps' -Version 'latest' -Retry 1 -Force -Path $tmp -SaveZip:$true -Interactive
        $res | Should -Be $tmp
    }

    It 'allows selection from multiple candidates by index' {
        # Build fake release with multiple assets
        $a1 = [pscustomobject]@{ name = 'spec-kit-template-alpha-ps-v1.0.0.zip'; browser_download_url = 'http://example.com/a1.zip' }
        $a2 = [pscustomobject]@{ name = 'spec-kit-template-beta-ps-v1.0.0.zip'; browser_download_url = 'http://example.com/a2.zip' }
        $fakeRelease = [pscustomobject]@{ assets = @($a1,$a2) }
        Mock -CommandName Get-LatestRelease -ModuleName PSSpecKit -MockWith { return $fakeRelease }

        # Simulate entering index '1' to pick 'beta'
        Mock -CommandName Read-Host -MockWith { return '1' }

    Mock -CommandName Find-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Release,$Agent,$Shell) return $a2 }
    Mock -CommandName Save-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Asset,$OutPath) return (Join-Path ([System.IO.Path]::GetTempPath()) $Asset.name) }
        Mock -CommandName Test-ZipArchive -ModuleName PSSpecKit -MockWith { return $true }
        Mock -CommandName Expand-SafeArchive -ModuleName PSSpecKit -MockWith { return $true }

        $tmp = Join-Path $PSScriptRoot 'tmp3'
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        $res = Install-SpecKitTemplate -Agent $null -Shell 'ps' -Version 'latest' -Retry 1 -Force -Path $tmp -SaveZip:$true -Interactive
        $res | Should -Be $tmp
    }
}
Describe 'Install-SpecKitTemplate interactive flows' {
    BeforeAll {
    # Import the module
        Import-Module "$PSScriptRoot\..\PSSpecKit\PSSpecKit.psd1" -Force
    }

    It 'prompts and accepts typed agent when no candidates found' {
        # Mock a release with no assets
        $fakeRelease = [pscustomobject]@{ assets = @() }
        Mock -CommandName Get-LatestRelease -ModuleName PSSpecKit -MockWith { return $fakeRelease }

        # Simulate user typing 'custom-agent' when prompted
        Mock -CommandName Read-Host -MockWith { return 'custom-agent' }

    Install-SpecKitTemplate -Agent $null -Shell 'ps' -Version 'latest' -Retry 1 -Force:$false -Path (Join-Path $PSScriptRoot 'tmp') -SaveZip:$false -Interactive | Out-Null
    # When no assets exist and user supplies custom-agent, Find-ReleaseAsset will be called with that name; the function will then throw later
    $global:SPEC_KIT_DOWNLOADER_EXCEPTION | Should -Not -BeNullOrEmpty
    }

    It 'confirms single candidate and accepts default when user presses Enter' {
        # Create a fake release with one matching asset
        $asset = [pscustomobject]@{ name = 'spec-kit-template-myagent-ps-v1.0.0.zip'; browser_download_url = 'http://example.com/asset.zip' }
        $fakeRelease = [pscustomobject]@{ assets = @($asset) }
        Mock -CommandName Get-LatestRelease -ModuleName PSSpecKit -MockWith { return $fakeRelease }

        # Mock Read-Host to simulate pressing Enter (empty input)
        Mock -CommandName Read-Host -MockWith { return '' }

        # Also mock Save-ReleaseAsset and Expand-SafeArchive to avoid network and disk operations
    Mock -CommandName Find-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Release,$Agent,$Shell) return $asset }
    Mock -CommandName Save-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Asset,$OutPath) return (Join-Path ([System.IO.Path]::GetTempPath()) $Asset.name) }
        Mock -CommandName Test-ZipArchive -ModuleName PSSpecKit -MockWith { return $true }
        Mock -CommandName Expand-SafeArchive -ModuleName PSSpecKit -MockWith { return $true }

        $tmp = Join-Path $PSScriptRoot 'tmp2'
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        $res = Install-SpecKitTemplate -Agent $null -Shell 'ps' -Version 'latest' -Retry 1 -Force -Path $tmp -SaveZip:$true -Interactive
        $res | Should -Be $tmp
    }

    It 'allows selection from multiple candidates by index' {
        # Build fake release with multiple assets
        $a1 = [pscustomobject]@{ name = 'spec-kit-template-alpha-ps-v1.0.0.zip'; browser_download_url = 'http://example.com/a1.zip' }
        $a2 = [pscustomobject]@{ name = 'spec-kit-template-beta-ps-v1.0.0.zip'; browser_download_url = 'http://example.com/a2.zip' }
        $fakeRelease = [pscustomobject]@{ assets = @($a1,$a2) }
        Mock -CommandName Get-LatestRelease -ModuleName PSSpecKit -MockWith { return $fakeRelease }

        # Simulate entering index '1' to pick 'beta'
        Mock -CommandName Read-Host -MockWith { return '1' }

    Mock -CommandName Find-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Release,$Agent,$Shell) return $a2 }
    Mock -CommandName Save-ReleaseAsset -ModuleName PSSpecKit -MockWith { param($Asset,$OutPath) return (Join-Path ([System.IO.Path]::GetTempPath()) $Asset.name) }
        Mock -CommandName Test-ZipArchive -ModuleName PSSpecKit -MockWith { return $true }
        Mock -CommandName Expand-SafeArchive -ModuleName PSSpecKit -MockWith { return $true }

        $tmp = Join-Path $PSScriptRoot 'tmp3'
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        $res = Install-SpecKitTemplate -Agent $null -Shell 'ps' -Version 'latest' -Retry 1 -Force -Path $tmp -SaveZip:$true -Interactive
        $res | Should -Be $tmp
    }
}
