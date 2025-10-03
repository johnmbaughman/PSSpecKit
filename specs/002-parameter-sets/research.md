# research.md — ParameterSet enhancement for Install-SpecKitTemplate

Date: 2025-10-02
Spec source: `C:\Personal\Files\source\repos\PSSpecKit\specs\feat\paramsets-install-speckit\spec.md`

## Purpose & Goals
- Resolve technical unknowns for implementing two ParameterSets (`Interactive`, `Noninteractive`) in a PowerShell script.
- Produce design decisions, constraints, and recommended implementations that minimize rework and align with the repo constitution.

## Extracted Unknowns / Clarifications (resolved)
- Overwrite confirmation scope: single prompt only when targets exist; includes "Yes to all / No to all".
- Non-TTY behavior for `-Interactive`: fail immediately with exit code 2.
- SaveZip/Retry prompting: do not prompt; use defaults unless provided.
- Parameter-set validation: strict validation; error the run if incompatible parameters supplied.
- Exit codes: 1=general, 2=TTY/interactive, 3=validation/user-decline.

## Technical Context
- Language: PowerShell (pwsh 7+ preferred)
- Testing: Pester v5 (existing helper `tools/run-pester-v5.ps1`)
- Linting: PSScriptAnalyzer (required by constitution)
- Primary files touched: `tools/Install-SpecKitTemplate.ps1`, `tests/*.Tests.ps1`
- Platform: cross-platform (Windows/macOS/Linux) but interactive TTY semantics must be handled portably.

## Decisions & Rationale
1. ParameterSet approach
   - Decision: Use PowerShell ParameterSet attributes (`ParameterSetName`) on Param block and function to create `Interactive` and `Noninteractive` sets.
   - Rationale: Native cmdlet semantics ensure binding and validation integrate with PowerShell's parameter binder.

2. Interactive prompting behavior
   - Decision: Prompt only for missing values when `-Interactive` is present; respect supplied parameters; present overwrite prompt only when targets exist; do not prompt for SaveZip/Retry.
   - Rationale: Minimizes surprise; allows scripts to supply some values while enabling interactive confirmation; matches previous clarifications.

3. TTY detection & failure mode
   - Decision: Detect TTY via `$Host.UI.RawUI` and fall back to failing with exit code 2 when missing.
   - Rationale: Portable and consistent across pwsh hosts in CI.

4. Exit codes
   - Decision: Use exit code mapping: 1=general, 2=TTY/interactive, 3=validation/user-decline.
   - Rationale: Distinct codes simplify automated tests and CI checks.

5. Safe extraction
   - Decision: Extract zip contents into a temp folder, validate artifact integrity, then move into target path; use `Expand-Archive` or `System.IO.Compression.ZipFile` cautiously and validate presence of expected files.
   - Rationale: Prevent partial writes and reduce corruption risk on interrupts.

## Risks & Mitigations
- Risk: `$Host.UI.RawUI` not available in some hosts -> Mitigation: check for its presence and class; if missing, treat as non-TTY and error.
- Risk: Tests that mock TTY behavior may be brittle -> Mitigation: centralize TTY check into a small function that tests can mock.

## Next steps (Phase 1 inputs)
- Create `data-model.md` (entities: parameters, run context, exit codes)
- Create `quickstart.md` with example commands and test scenarios
- Enumerate contract/test cases for Pester

