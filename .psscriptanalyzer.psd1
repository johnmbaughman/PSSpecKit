@{
    # Basic PSScriptAnalyzer settings tuned for this project
    # Rules must be provided as a hashtable mapping rule names to settings
    # NOTE: When running PSScriptAnalyzer, exclude the .specify directory as it contains
    # internal tooling scripts that are not part of the application:
    # Invoke-ScriptAnalyzer -Path . -Settings .psscriptanalyzer.psd1 -Recurse -ExcludePath .specify
    Rules = @{
        PSUseApprovedVerbs = @{ Enable = $true }
        PSAvoidUsingPlainTextForPassword = @{ Enable = $true }
        PSAvoidUsingWriteHost = @{ Enable = $true }
        PSUseSingularNouns = @{ Enable = $true }
        PSUseDeclaredVarsMoreThanAssignments = @{ Enable = $true }
    }
    ExcludeRules = @(
        'PSUseOutputType' # allow scripts without output type declarations for CLI helpers
    )
}
