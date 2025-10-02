@{
    # Basic PSScriptAnalyzer settings tuned for this project
    Rules = @(
        'PSUseApprovedVerbs',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingWriteHost',
        'PSUseSingularNouns',
        'PSUseDeclaredVarsMoreThanAssignments'
    )
    ExcludeRules = @(
        'PSUseOutputType' # allow scripts without output type declarations for CLI helpers
    )
    Severity = @{
        PSUseApprovedVerbs = 'Warning'
        PSAvoidUsingWriteHost = 'Warning'
    }
}
