# Requires: PowerShell 7+
Describe 'SpecKitDownloader' {
    # Dot-source the script once so helper functions are available to all tests
    BeforeAll {
        . "$PSScriptRoot\..\tools\spec-kit-downloader.ps1"
        # Ensure sample.zip exists for extraction tests
        & "$PSScriptRoot\create-sample-zip.ps1"
    }

    Context 'Unit tests' {
        It 'Validate-Zip returns false for invalid file' {
            $temp = [System.IO.Path]::GetTempFileName()
            Set-Content -Path $temp -Value 'not a zip'
            # Validate-Zip may emit log strings; pick the last boolean result
            $result = Validate-Zip -ZipPath $temp | Where-Object { $_ -is [bool] } | Select-Object -Last 1
            Remove-Item $temp -Force
            $result | Should -BeFalse
        }

        It 'Safe-Extract copies files and respects skip when not forced' {
            $sampleZip = Join-Path -Path $PSScriptRoot -ChildPath 'sample.zip'
            $extractDir = Join-Path -Path $PSScriptRoot -ChildPath 'out'
            if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
            $ok = Safe-Extract -ZipPath $sampleZip -TargetPath $extractDir
            $ok | Should -BeTrue
            (Test-Path (Join-Path $extractDir 'hello.txt')) | Should -BeTrue

            # Run again without Force - should skip existing file but still return true
            $ok2 = Safe-Extract -ZipPath $sampleZip -TargetPath $extractDir
            $ok2 | Should -BeTrue

            # Cleanup
            Remove-Item $extractDir -Recurse -Force
        }
    }

    # Integration tests can be added here later
}
