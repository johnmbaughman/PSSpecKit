<#
Helper test host objects and prompt transcript utilities for Pester tests.

Provides:
 - New-TestHostInteractive
 - New-TestHostNonInteractive
 - Start-TestPromptTranscript
 - Add-TestPromptEntry
 - Get-TestPromptTranscript
 - Clear-TestPromptTranscript

#>

function New-TestHostInteractive {
    <# Creates a PSCustomObject that mimics $Host with UI.RawUI that indicates a TTY is available. #>
    $rawUI = [PSCustomObject]@{
        KeyAvailable    = $true
        CursorSize      = 1
        BackgroundColor = 'Black'
        ForegroundColor = 'White'
        WindowSize      = [PSCustomObject]@{ Width = 120; Height = 30 }
        BufferSize      = [PSCustomObject]@{ Width = 120; Height = 300 }
        CursorPosition  = [PSCustomObject]@{ X = 0; Y = 0 }
    }

    $ui = [PSCustomObject]@{ RawUI = $rawUI }
    $testHostObj = [PSCustomObject]@{ Name = 'TestHost'; UI = $ui }
    return $testHostObj
}

function New-TestHostNonInteractive {
    <# Creates a PSCustomObject that mimics $Host without TTY support (KeyAvailable = $false). #>
    $rawUI = [PSCustomObject]@{
        KeyAvailable    = $false
        CursorSize      = 1
        BackgroundColor = 'Black'
        ForegroundColor = 'White'
        WindowSize      = [PSCustomObject]@{ Width = 80; Height = 25 }
        BufferSize      = [PSCustomObject]@{ Width = 80; Height = 200 }
        CursorPosition  = [PSCustomObject]@{ X = 0; Y = 0 }
    }

    $ui = [PSCustomObject]@{ RawUI = $rawUI }
    $testHostObj = [PSCustomObject]@{ Name = 'TestHost'; UI = $ui }
    return $testHostObj
}

# Prompt transcript utilities (simple in-memory capture for tests)
if (-not (Test-Path -LiteralPath variable:TestHostPromptTranscript -ErrorAction SilentlyContinue)) {
    Set-Variable -Name TestHostPromptTranscript -Scope Script -Value @()
}

function Start-TestPromptTranscript {
    Set-Variable -Name TestHostPromptTranscript -Scope Script -Value @()
}

function Add-TestPromptEntry {
    param(
        [Parameter(Mandatory=$true)] [string] $Prompt,
        [Parameter(Mandatory=$true)] [string] $Response
    )
    $entry = [PSCustomObject]@{
        Time     = (Get-Date).ToString('o')
        Prompt   = $Prompt
        Response = $Response
    }
    $script:TestHostPromptTranscript += $entry
}

function Get-TestPromptTranscript {
    return ,$script:TestHostPromptTranscript
}

function Clear-TestPromptTranscript {
    Set-Variable -Name TestHostPromptTranscript -Scope Script -Value @()
}

# Intentionally do not call Export-ModuleMember here so the file can be dot-sourced from tests.
