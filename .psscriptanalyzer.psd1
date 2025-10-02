@{
    # Basic PSScriptAnalyzer settings tuned for this project
    # Rules must be provided as a hashtable mapping rule names to settings
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
