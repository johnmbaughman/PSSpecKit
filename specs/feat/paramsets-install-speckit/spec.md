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
- Q: How should `-Force` be handled across parameter sets? → A: Allow `-Force` only in the `Noninteractive` set; interactive runs rely on the overwrite prompt.
- Q: How should blank interactive prompt input be handled? → A: Accept blank input, echo the default being used, then continue.
- Q: When should "Yes to all / No to all" appear in overwrite prompts? → A: Always include these options, even if only one target is affected.
- Q: How should the installer script use the module directory? → A: Import the module at runtime and call its exported functions.
- Q: What is the default path when Enter is pressed interactively? → A: Use the current working directory as the default.

## Execution Flow (main)

1. Introduce two ParameterSets for `Install-SpecKitTemplate.ps1`: `Interactive` and `Noninteractive`.
2. `Interactive` parameter set uses the existing `-Interactive` switch and will cause the script to prompt
  for Agent, Shell, Version, and Path values at runtime. Defaults remain as currently configured. When
  the user presses Enter without input, the script accepts the default (current working directory for Path)
  and echoes the value being used before proceeding.
  When overriding existing files, prompt the user with a clear warning confirming overwrite.
3. `Noninteractive` parameter set accepts all parameters explicitly (Agent, Shell, Version, Path, Force,
   SaveZip, Retry) and preserves existing behavior.
4. `SaveZip` and `Retry` remain as parameters available to both parameter sets.

## Quick Guidelines

- `Interactive` set: minimalist invocation using `-Interactive` only. Prompts must be clear and allow
  sane defaults; confirmation prompts for destructive choices (overwrite) are required. When users accept
  defaults by pressing Enter, echo the chosen default before continuing (Path defaults to the current
  working directory).
- Prompts SHOULD only appear if one or more target files or directories already exist. When prompting
  about overwrites, present a single confirmation that always includes a "Yes to all / No to all" choice
  so users can accept or reject overwriting all detected targets in one response.
- A confirmation prompt MUST appear when all prompts answers are collected, summarizing the choices
  and asking for final confirmation to proceed (Yes / No).
- `Noninteractive` set: full parametrization for CI and scripts; no interactive prompts. `-Force` is
  exclusive to this set.

Note: `SaveZip` and `Retry` remain configurable via parameters in both sets but will not trigger a prompt
in `-Interactive` runs — the script will use configured defaults unless the user explicitly passes those
parameters on the command line.

## User Scenarios & Testing

### Primary User Story
After moving the script to a modular structure, and as a developer or automation user, I want the 
installer script to support an interactive workflow for local runs and a fully parameterized 
non-interactive workflow for CI, so that local discovery and automation both remain ergonomic and 
predictable. Script now uses a module found in the PSSpecKit module directory. 

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
  parameters to those sets as described, ensuring `-Force` is only available in the `Noninteractive` set.
- **FR-002**: `-Interactive` switch MUST cause the script to prompt for Agent, Shell, Version, and Path.
- **FR-003**: Force prompting in Interactive mode MUST include an explicit overwrite confirmation when files
  already exist.
- **FR-004**: `SaveZip` and `Retry` MUST be available in both parameter sets and behave as currently defined. In
  `Interactive` runs these values will default to the script's configured defaults and will not be prompted for
  unless explicitly supplied on the command line.
- **FR-005**: Script MUST detect non-TTY environments and fail immediately with a descriptive error and exit code 2 when `-Interactive` is used.
- **FR-006**: Script MUST import the module located in the PSSpecKit module directory at runtime and call its exported functions for core functionality, ensuring modularity and maintainability.

## Key Entities
- `Agent`: short string representing the target agent name in the release assets.
- `Shell`: either `ps` or `sh` for PowerShell or shell templates.
- `Version`: release tag or `latest`.

## Review & Acceptance Checklist
- [ ] ParameterSets implemented and documented in script help
- [ ] Interactive prompts return values consistent with noninteractive behavior
- [ ] Pester tests added/updated for parameter set behaviors (mock Read-Host and environment)
- [ ] CI verifies noninteractive flows and runs PSScriptAnalyzer + Pester
