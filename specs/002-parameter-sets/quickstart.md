# quickstart.md — ParameterSet enhancement for Install-SpecKitTemplate

Date: 2025-10-02
Spec source: `C:\Personal\Files\source\repos\PSSpecKit\specs\feat\paramsets-install-speckit\spec.md`

## Examples

### Interactive local run
Run the installer and answer prompts when asked.

pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 -Interactive

Expected flow:
- Prompts for missing Agent, Shell, Version, Path, Force
- If files exist, one confirmation prompt: Yes/YesToAll/No/NoToAll
- SaveZip/Retry use defaults unless explicitly provided

### Noninteractive CI run
Supply all parameters on the command line for CI usage.

pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 -Agent copilot -Shell ps -Version latest -Force -SaveZip -Retry 3

Expected flow:
- No prompts; script runs to completion or exits with a non-zero code on failure

### Error modes
- Running `-Interactive` in CI (no TTY) should exit with code 2 and a descriptive message
- Supplying incompatible parameters should fail with exit code 3

## Test scenarios
- TTY present: `-Interactive` prompts and proceeds on Yes
- TTY absent: `-Interactive` exits code 2
- Overwrite: detect existing targets, user replies No → exit code 3
- SaveZip behavior: default used in interactive, explicit flag respected

