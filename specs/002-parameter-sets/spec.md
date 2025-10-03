# Feature: ParameterSet enhancement for Install-SpecKitTemplate

**Feature Branch**: `feat/paramsets-install-speckit`
**Created**: 2025-10-02
**Status**: Draft

## Clarifications

### Session 2025-10-02

- Q: Overwrite confirmation scope (required for FR-003) → A: Only prompt if files exist; single confirmation with "Yes to all / No to all" (Option C).
- Q: Behavior when `-Interactive` is used in a non-TTY environment (required for FR-005) → A: Fail immediately with a descriptive error and exit code 2 (Option A).
- Q: Prompting for `SaveZip` and `Retry` during interactive runs (affects FR-004) → A: Do not prompt; use script defaults unless parameters explicitly passed (Option B).
- Q: Parameter-set validation behavior (general) → A: Follow strict parameter-set validation rules and error the run if incompatible parameters are supplied for the selected parameter set.
- Q: Standardized exit code mapping (affects tests & automation) → A: Use exit code 1 for general errors; 2 for Interactive/TTY errors; 3 for validation/parameter-set errors (Option A).

## Execution Flow (main)

1. Introduce two ParameterSets for `Install-SpecKitTemplate.ps1`: `Interactive` and `Noninteractive`.
2. `Interactive` parameter set uses the existing `-Interactive` switch and will cause the script to prompt
   for Agent, Shell, Version, Path, and Force values at runtime. Defaults remain as currently configured.
   When overriding existing files with `-Force`, prompt the user with a clear warning confirming overwrite.
3. `Noninteractive` parameter set accepts all parameters explicitly (Agent, Shell, Version, Path, Force,
   SaveZip, Retry) and preserves existing behavior.
4. `SaveZip` and `Retry` remain as parameters available to both parameter sets.

## Quick Guidelines

- `Interactive` set: minimalist invocation using `-Interactive` only. Prompts must be clear and allow
  sane defaults; confirmation prompts for destructive choices (Force overwrite) are required.
- Prompts SHOULD only appear if one or more target files or directories already exist. When prompting
  about overwrites, present a single confirmation that includes a "Yes to all / No to all" choice so
  users can accept or reject overwriting all detected targets in one response.
- `Noninteractive` set: full parametrization for CI and scripts; no interactive prompts.

Note: `SaveZip` and `Retry` remain configurable via parameters in both sets but will not trigger a prompt
in `-Interactive` runs — the script will use configured defaults unless the user explicitly passes those
parameters on the command line.

## User Scenarios & Testing

### Primary User Story
As a developer or automation user, I want the installer script to support an interactive workflow for
local runs and a fully parameterized non-interactive workflow for CI, so that local discovery and
automation both remain ergonomic and predictable.

### Acceptance Scenarios
1. Given a direct shell invocation `pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 -Interactive`,
   When no Agent/Shell/Version/Path are provided, Then the script prompts for those values and proceeds
   with the provided inputs.
2. Given a CI invocation `pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 -Agent copilot -Shell ps -Version latest -Force -SaveZip -Retry 3`,
   When executed, Then the script runs non-interactively and completes without prompting.
3. Given `-Interactive` and the user accepts defaults, Then behavior matches a default noninteractive run
   for the supplied defaults (SaveZip/Retry use their supplied or default values).
4. Given `-Interactive -Agent copilot -Force` and `Force` is not allowed in the `Interactive` set (example),
  Then the script MUST fail parameter binding/validation and exit with a descriptive error (non-zero exit code).

### Edge Cases
- If `-Interactive` is set but the process has no TTY (noninteractive environment), the script MUST error
  with a clear message and exit code indicating interactive mode cannot run in this environment (use exit code 2).
- If `-Ice` (typo) or unknown parameter is supplied, the script MUST fail parameter binding as usual.
- If overwrite targets are detected and the user selects the negative choice (No / No to all), the script
  MUST abort without modifying existing files and exit with exit code 3 (user-declined overwrite). If the user
  selects the affirmative (Yes / Yes to all) the script proceeds to overwrite according to the `-Force` semantics.

- If parameters incompatible with the selected ParameterSet are supplied (e.g., supplying interactive-only
  parameters in a noninteractive run or vice versa), the script MUST fail fast during parameter binding or
  validation with a descriptive error and exit code 3.

### Exit Code Summary

- 1 — General errors (fallback/default non-specific failures)
- 2 — Interactive / TTY related errors (e.g., `-Interactive` used in non-TTY)
- 3 — Validation / parameter-set errors (including user-declined overwrite)

## Requirements

### Functional Requirements
- **FR-001**: Script MUST expose two parameter sets (`Interactive`, `Noninteractive`) and associate
  parameters to those sets as described.
- **FR-002**: `-Interactive` switch MUST cause the script to prompt for Agent, Shell, Version, Path, and Force.
- **FR-003**: Force prompting in Interactive mode MUST include an explicit overwrite confirmation when files
  already exist.
- **FR-004**: `SaveZip` and `Retry` MUST be available in both parameter sets and behave as currently defined. In
  `Interactive` runs these values will default to the script's configured defaults and will not be prompted for
  unless explicitly supplied on the command line.
- **FR-005**: Script MUST detect non-TTY environments and fail immediately with a descriptive error and exit code 2 when `-Interactive` is used.

## Key Entities
- `Agent`: short string representing the target agent name in the release assets.
- `Shell`: either `ps` or `sh` for PowerShell or shell templates.
- `Version`: release tag or `latest`.

## Review & Acceptance Checklist
- [ ] ParameterSets implemented and documented in script help
- [ ] Interactive prompts return values consistent with noninteractive behavior
- [ ] Pester tests added/updated for parameter set behaviors (mock Read-Host and environment)
- [ ] CI verifies noninteractive flows and runs PSScriptAnalyzer + Pester
