<#
Scans PowerShell files in the repo for absolute paths like C:\ or \\\server\share and exits non-zero if any are found.
This is intentionally simple: it looks for common absolute path patterns in string literals and comments.
#>
Param(
    [string]$Path = (Get-Location).Path
)

Write-Output "Scanning repository files for absolute paths under: $Path"

$patterns = @(
    '[A-Za-z]:\\',    # Windows drive letter
    '\\\\[A-Za-z0-9_.-]+'  # UNC path like \\server\share
)

$files = Get-ChildItem -Path $Path -Include *.ps1,*.psm1,*.psd1 -Recurse -File -ErrorAction SilentlyContinue
$issues = @()
# Files or folders to exclude from scanning (allowlist)
$excludePaths = @(
    '.specify',
    'scripts\check-absolute-paths.ps1'
)
foreach ($f in $files) {
    # Skip excluded paths
    if ($excludePaths | Where-Object { $f.FullName -like "*$_*" }) { continue }
    $text = Get-Content -Raw -Path $f.FullName -ErrorAction SilentlyContinue
    foreach ($p in $patterns) {
        if ($text -match $p) {
            $foundMatches = [regex]::Matches($text, $p) | ForEach-Object { $_.Value }
            # Filter out known false positives like escaped newline literal '\n'
            $filtered = $foundMatches | Where-Object { $_ -ne '\n' }
            if ($filtered.Count -gt 0) {
                $issues += [PSCustomObject]@{ File = $f.FullName; Pattern = $p; Matches = ($filtered -join ', ') }
            }
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Error "Absolute path usage detected in the following files (policy: no absolute paths in scripts):"
    $issues | Format-Table -AutoSize
    exit 2
} else {
    Write-Output "No absolute paths detected."
    exit 0
}
