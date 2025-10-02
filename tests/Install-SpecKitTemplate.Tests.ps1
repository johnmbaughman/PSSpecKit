# Requires: PowerShell 7+
Describe 'Install-SpecKitTemplate' {
    # Import the module so functions are available to all tests
    BeforeAll {
        Import-Module "$PSScriptRoot\..\PSSpecKit\PSSpecKit.psd1" -Force
        # Ensure sample.zip exists for extraction tests
        & "$PSScriptRoot\create-sample-zip.ps1"
    }

    Context 'Unit tests' {
        It 'Test-ZipArchive returns false for invalid file' {
            $temp = [System.IO.Path]::GetTempFileName()
            Set-Content -Path $temp -Value 'not a zip'
            # Test-ZipArchive may emit log strings; pick the last boolean result
            $result = Test-ZipArchive -ZipPath $temp | Where-Object { $_ -is [bool] } | Select-Object -Last 1
            Remove-Item $temp -Force
            $result | Should -BeFalse
        }

        It 'Expand-SafeArchive copies files and respects skip when not forced' {
            $sampleZip = Join-Path -Path $PSScriptRoot -ChildPath 'sample.zip'
            $extractDir = Join-Path -Path $PSScriptRoot -ChildPath 'out'
            if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
            $ok = Expand-SafeArchive -ZipPath $sampleZip -TargetPath $extractDir
            $ok | Should -BeTrue
            (Test-Path (Join-Path $extractDir 'hello.txt')) | Should -BeTrue

            # Run again without Force - should skip existing file but still return true
            $ok2 = Expand-SafeArchive -ZipPath $sampleZip -TargetPath $extractDir
            $ok2 | Should -BeTrue

            # Cleanup
            Remove-Item $extractDir -Recurse -Force
        }
    }

    Context 'Failure path tests' {
        It 'Install-SpecKitTemplate returns false when release asset is missing' {
            # Provide an unlikely agent/shell combo so asset lookup fails quickly
            $ok = Install-SpecKitTemplate -Agent 'doesnotexist' -Shell 'ps' -Version 'nonexistent' -Retry 1 -Path (Join-Path $PSScriptRoot 'tmp')
            $ok | Should -BeFalse
        }
    }

    # Integration tests can be added here later
}
# Requires: PowerShell 7+
Describe 'Install-SpecKitTemplate' {
    # Import the module so functions are available to all tests
    BeforeAll {
        Import-Module "$PSScriptRoot\..\PSSpecKit\PSSpecKit.psd1" -Force
        # Ensure sample.zip exists for extraction tests
        & "$PSScriptRoot\create-sample-zip.ps1"
    }

    Context 'Unit tests' {
        It 'Test-ZipArchive returns false for invalid file' {
            $temp = [System.IO.Path]::GetTempFileName()
            Set-Content -Path $temp -Value 'not a zip'
            # Test-ZipArchive may emit log strings; pick the last boolean result
            $result = Test-ZipArchive -ZipPath $temp | Where-Object { $_ -is [bool] } | Select-Object -Last 1
            Remove-Item $temp -Force
            $result | Should -BeFalse
        }

        It 'Expand-SafeArchive copies files and respects skip when not forced' {
            $sampleZip = Join-Path -Path $PSScriptRoot -ChildPath 'sample.zip'
            $extractDir = Join-Path -Path $PSScriptRoot -ChildPath 'out'
            if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
            $ok = Expand-SafeArchive -ZipPath $sampleZip -TargetPath $extractDir
            $ok | Should -BeTrue
            (Test-Path (Join-Path $extractDir 'hello.txt')) | Should -BeTrue

            # Run again without Force - should skip existing file but still return true
            $ok2 = Expand-SafeArchive -ZipPath $sampleZip -TargetPath $extractDir
            $ok2 | Should -BeTrue

            # Cleanup
            Remove-Item $extractDir -Recurse -Force
        }
    }

    Context 'Failure path tests' {
        It 'Install-SpecKitTemplate returns false when release asset is missing' {
            # Provide an unlikely agent/shell combo so asset lookup fails quickly
            $ok = Install-SpecKitTemplate -Agent 'doesnotexist' -Shell 'ps' -Version 'nonexistent' -Retry 1 -Path (Join-Path $PSScriptRoot 'tmp')
            $ok | Should -BeFalse
        }
    }

    # Integration tests can be added here later
}
