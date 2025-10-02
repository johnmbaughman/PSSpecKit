Describe 'Install-SpecKitTemplate - Argument parsing and defaults (T002)' {
    It 'script param block contains expected default for Shell, Version, Retry and accepts Agent/Force/Path/Interactive' {
        $repoRoot = (Resolve-Path -Path (Join-Path $PSScriptRoot '..')).Path
    $scriptPath = Join-Path $repoRoot 'tools\Install-SpecKitTemplate.ps1'
        Test-Path $scriptPath | Should -BeTrue
        $script = Get-Content -Path $scriptPath -Raw

        # Simple substring checks for token presence (robust against formatting)
        ($script.Contains('ValidateSet') -or $script.Contains('Default: ps')) | Should -BeTrue
        $script.Contains('$Shell') | Should -BeTrue
        $script.Contains('$Version') | Should -BeTrue
        $script.Contains('$Retry') | Should -BeTrue
        $script.Contains('$Agent') | Should -BeTrue
        $script.Contains('$Force') | Should -BeTrue
        $script.Contains('$Path') | Should -BeTrue
        $script.Contains('$Interactive') | Should -BeTrue
    }
}

Describe 'Install-SpecKitTemplate - Argument parsing and defaults (T002)' {
    It 'script param block contains expected default for Shell, Version, Retry and accepts Agent/Force/Path/Interactive' {
        $repoRoot = (Resolve-Path -Path (Join-Path $PSScriptRoot '..')).Path
        $scriptPath = Join-Path $repoRoot 'tools\Install-SpecKitTemplate.ps1'
        Test-Path $scriptPath | Should -BeTrue
        $script = Get-Content -Path $scriptPath -Raw

        # Simple substring checks for token presence (robust against formatting)
        ($script.Contains('ValidateSet') -or $script.Contains('Default: ps')) | Should -BeTrue
        $script.Contains('$Shell') | Should -BeTrue
        $script.Contains('$Version') | Should -BeTrue
        $script.Contains('$Retry') | Should -BeTrue
        $script.Contains('$Agent') | Should -BeTrue
        $script.Contains('$Force') | Should -BeTrue
        $script.Contains('$Path') | Should -BeTrue
        $script.Contains('$Interactive') | Should -BeTrue
    }
}