Describe 'Install-SpecKitTemplate - Asset selection (T003)' {
    BeforeAll {
    . $PSScriptRoot\..\tools\Install-SpecKitTemplate.ps1
        # Create a fake release object
        $global:fakeRelease = [pscustomobject]@{
            assets = @(
                [pscustomobject]@{ name = 'spec-kit-template-copilot-ps-v0.0.1.zip'; browser_download_url = 'https://example.com/1' },
                [pscustomobject]@{ name = 'spec-kit-template-copilot-sh-v0.0.1.zip'; browser_download_url = 'https://example.com/2' },
                [pscustomobject]@{ name = 'spec-kit-template-foo-ps-v0.0.2.zip'; browser_download_url = 'https://example.com/3' }
            )
        }
    }

    It 'Find-ReleaseAsset picks the ps asset for copilot when shell=ps' {
        $asset = Find-ReleaseAsset -Release $global:fakeRelease -Agent 'copilot' -Shell 'ps'
        $asset | Should -Not -BeNullOrEmpty
        $asset.name | Should -Match 'copilot-ps'
    }

    It 'Find-ReleaseAsset picks the sh asset for copilot when shell=sh' {
        $asset = Find-ReleaseAsset -Release $global:fakeRelease -Agent 'copilot' -Shell 'sh'
        $asset | Should -Not -BeNullOrEmpty
        $asset.name | Should -Match 'copilot-sh'
    }

    It 'Find-ReleaseAsset falls back when agent omitted' {
        $asset = Find-ReleaseAsset -Release $global:fakeRelease -Agent 'foo' -Shell 'ps'
        $asset | Should -Not -BeNullOrEmpty
        $asset.name | Should -Match 'foo-ps'
    }
}
Describe 'Install-SpecKitTemplate - Asset selection (T003)' {
    BeforeAll {
    . $PSScriptRoot\..\tools\Install-SpecKitTemplate.ps1
        # Create a fake release object
        $global:fakeRelease = [pscustomobject]@{
            assets = @(
                [pscustomobject]@{ name = 'spec-kit-template-copilot-ps-v0.0.1.zip'; browser_download_url = 'https://example.com/1' },
                [pscustomobject]@{ name = 'spec-kit-template-copilot-sh-v0.0.1.zip'; browser_download_url = 'https://example.com/2' },
                [pscustomobject]@{ name = 'spec-kit-template-foo-ps-v0.0.2.zip'; browser_download_url = 'https://example.com/3' }
            )
        }
    }

    It 'Find-ReleaseAsset picks the ps asset for copilot when shell=ps' {
        $asset = Find-ReleaseAsset -Release $global:fakeRelease -Agent 'copilot' -Shell 'ps'
        $asset | Should -Not -BeNullOrEmpty
        $asset.name | Should -Match 'copilot-ps'
    }

    It 'Find-ReleaseAsset picks the sh asset for copilot when shell=sh' {
        $asset = Find-ReleaseAsset -Release $global:fakeRelease -Agent 'copilot' -Shell 'sh'
        $asset | Should -Not -BeNullOrEmpty
        $asset.name | Should -Match 'copilot-sh'
    }

    It 'Find-ReleaseAsset falls back when agent omitted' {
        $asset = Find-ReleaseAsset -Release $global:fakeRelease -Agent 'foo' -Shell 'ps'
        $asset | Should -Not -BeNullOrEmpty
        $asset.name | Should -Match 'foo-ps'
    }
}
