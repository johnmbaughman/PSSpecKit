# tasks.md — ParameterSet enhancement for Install-SpecKitTemplate

Feature: ParameterSet enhancement for `tools/Install-SpecKitTemplate.ps1`
Feature directory: `C:\Personal\Files\source\repos\PSSpecKit\specs\feat\paramsets-install-speckit`
Spec source: `C:\Personal\Files\source\repos\PSSpecKit\specs\feat\paramsets-install-speckit\spec.md`

Overview: Implement two ParameterSets (`Interactive`, `Noninteractive`) with strict validation, interactive prompting rules, safe extraction, and clear exit codes. Tasks follow TDD: tests first, then implementation.

Task numbering rules: T001..T0NN. Tasks marked [P] can be executed in parallel when they edit different files.

T001 — Setup: Verify test and lint tooling
- Path: `tools/run-pester-v5.ps1`, `.github/workflows/*` (CI)
- Action: Ensure `tools/run-pester-v5.ps1` exists and is executable. Add/update `.github/workflows/pester-and-lint.yml` to run Pester v5 and PSScriptAnalyzer on PRs and pushes to feature branches.
- Output: CI YAML that runs Pester (v5) and PSScriptAnalyzer
- Depends on: none

T002 [P] — Test: ParameterSet binding & validation (Pester)
- Path: `tests/Install-SpecKitTemplate.ParameterSet.Tests.ps1`
- Action: Create Pester tests to assert:
  * `-Interactive` selects Interactive ParameterSet
  * Supplying incompatible parameters causes binding/validation failure (exit code 3)
  * `-Interactive` in non-TTY exits with code 2
  * SaveZip/Retry defaults behavior in Interactive
- Output: Tests failing initially (TDD)
- Depends on: T001

T003 [P] — Test: Prompting behavior (mock Read-Host)
- Path: `tests/Install-SpecKitTemplate.Prompting.Tests.ps1`
- Action: Create Pester tests that mock `Read-Host` (and central TTY check function) to simulate user answers, asserting prompts only for missing values and overwrite confirmation behavior (Yes/YesToAll/No/NoToAll), No → exit code 3.
- Output: Failing tests
- Depends on: T001

T004 — Core: Param block & ParameterSet declarations
- Path: `tools/Install-SpecKitTemplate.ps1`
- Action: Add `ParameterSetName` attributes to the param block and function. Implement a central `Validate-ParameterSet` function that errors for incompatible parameter combinations with exit code 3.
- Output: Script updated with ParameterSets and validation scaffolding
- Depends on: T002, T003

T005 — Core: TTY check & interactive prompting
- Path: `tools/Install-SpecKitTemplate.ps1`
- Action: Implement `Test-IsTty` helper (mockable). When `-Interactive` used, call `Test-IsTty` and exit code 2 if false. Prompt for missing Agent, Shell, Version, Path, Force using `Read-Host`, pre-fill prompts with supplied values when present.
- Note: Do not prompt for SaveZip/Retry — use defaults unless flags present.
- Output: Prompting implemented and covered by tests
- Depends on: T004

T006 — Core: Overwrite confirmation & safe extraction
- Path: `tools/Install-SpecKitTemplate.ps1` and helper functions in `tools/helpers.ps1` (optional)
- Action: Implement detection of existing targets; if any found, present single overwrite confirmation (Yes/YesToAll/No/NoToAll). If user selects No/NoToAll, exit with code 3. Implement `Expand-SafeArchive` that extracts to temp folder, validates files, then moves into place. Respect `-Force` semantics.
- Output: Overwrite & extraction logic
- Depends on: T005

T007 — Integration: End-to-end integration tests
- Path: `tests/Install-SpecKitTemplate.Integration.Tests.ps1`
- Action: Add integration tests that run the script against a local sample zip (use `tests/create-sample-zip.ps1`), assert file outputs, and verify exit codes for error conditions.
- Output: Failing integration tests
- Depends on: T002, T003

T008 — Docs: Update comment-based help and README
- Path: `tools/Install-SpecKitTemplate.ps1` (help block) and `README.md`
- Action: Update script comment-based help to document both ParameterSets, examples, and exit codes. Update `README.md` with a short section on interactive vs noninteractive usage.
- Output: Documentation updated
- Depends on: T004..T006

T009 [P] — Polish: PSScriptAnalyzer baseline & CI gating
- Path: `.psscriptanalyzer.psd1`, `.github/workflows/pester-and-lint.yml`
- Action: Add a minimal PSScriptAnalyzer configuration; ensure CI fails on analyzer violations. Add caching where possible.
- Output: Linting baseline and CI integration
- Depends on: T001

T010 — Polish: Finalize tests and CI fixes
- Path: `tests/**/*.Tests.ps1`, `.github/workflows/*`
- Action: Iterate on tests to fix flakiness, add test coverage for edge cases, ensure CI passes.
- Output: All tests pass in CI locally reproducible
- Depends on: T006, T007, T009

Parallel execution examples
- Run parameter-set tests and prompting tests in parallel (different files):
  pwsh -NoProfile tools/run-pester-v5.ps1 -Path tests/Install-SpecKitTemplate.ParameterSet.Tests.ps1 &
  pwsh -NoProfile tools/run-pester-v5.ps1 -Path tests/Install-SpecKitTemplate.Prompting.Tests.ps1 &

- Run T009 (lint) in parallel with test development (T002/T003):
  pwsh -NoProfile .\tools\run-pester-v5.ps1 -Path tests
  pwsh -NoProfile pwsh -Command "Invoke-ScriptAnalyzer -Path tools -Recurse"  # example

Execution order summary
- Setup: T001
- Tests: T002, T003 (parallel) → T007 (after core)
- Core: T004 → T005 → T006
- Docs: T008
- Polish: T009 (parallel where possible) → T010

Saving file and marking tasks complete.
