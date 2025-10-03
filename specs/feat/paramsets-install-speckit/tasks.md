# Tasks: ParameterSet enhancement for Install-SpecKitTemplate

**Input**: `specs/feat/paramsets-install-speckit/spec.md`
**Feature Branch**: `feat/paramsets-install-speckit`
**Feature Directory**: `C:\Personal\Files\source\repos\PSSpecKit\specs\feat\paramsets-install-speckit`
**Available Docs**: `plan.md`, `research.md`, `data-model.md`, `contracts/Install-SpecKitTemplate.md`, `quickstart.md`

Follow these executable tasks in order. Tasks marked with **[P]** can run in parallel because they modify different files and have no dependency overlap. Each task lists required files, dependencies, and success criteria so an LLM or human can execute it without extra context.

-## Phase 3.1 – Setup
- [X] **T001** Prepare host simulation helpers for tests
  - Files: `tests/Support/HostMocks.ps1`
  - Work: Add a reusable helper module exposing `New-TestHostInteractive`, `New-TestHostNonInteractive`, and prompt transcript utilities so unit/integration tests can simulate TTY/non-TTY behavior without altering global host state.
  - Depends on: —
  - Blocks: T002, T003, T004, T005, T006
  - Success: Tests can `.`-source the helper and obtain host objects with `RawUI` members matching PowerShell expectations.

## Phase 3.2 – Tests First (author failing tests before implementation)
- [ ] **T002 [P]** Author contract tests for parameter sets
  - Files: `tests/Install-SpecKitTemplate.Contract.Tests.ps1`
  - Work: Create a Pester v5 describe block driven by `contracts/Install-SpecKitTemplate.md` that verifies mutually exclusive parameter sets, rejects `-Interactive -Force`, and asserts exit code 2 is documented for non-TTY interactive runs.
  - Depends on: T001
  - Blocks: T007, T008, T009, T010, T011
  - Success: Tests fail because the script/module do not yet enforce the documented contract.

- [ ] **T003 [P]** Extend argument-binding tests for noninteractive CLI usage
  - Files: `tests/Install-SpecKitTemplate.Args.Tests.ps1`
  - Work: Add Pester cases that call the script with `pwsh -File` via `Start-Process`/`&` to assert required parameters (`Agent`, `Shell`, `Version`) and verify missing values or invalid combinations emit exit code 3 with validation messaging.
  - Depends on: T001
  - Blocks: T010, T011
  - Success: New tests fail, showing current implementation does not emit the expected exit codes or validation errors.

- [ ] **T004 [P]** Expand interactive prompt flow tests
  - Files: `tests/Install-SpecKitTemplate.Interactive.Tests.ps1`
  - Work: Use the new host mocks to simulate accepting defaults, declining overwrite, and confirming the recap. Assert prompt sequence (Agent → Shell → Version → Path → overwrite confirmation → summary) and exit code 3 when the user declines.
  - Depends on: T001
  - Blocks: T009, T010
  - Success: Tests fail because prompts are not yet orchestrated in the required order or do not echo defaults.

- [ ] **T005 [P]** Cover exit-code routing and module import detection
  - Files: `tests/Install-SpecKitTemplate.Tests.ps1`
  - Work: Add cases that verify the script imports `PSSpecKit.psm1` via `$PSScriptRoot`, maps module exceptions to exit codes (0/1/3), and records `$script:LastException` for diagnostics.
  - Depends on: T001
  - Blocks: T007, T008, T010, T011
  - Success: Tests fail because the script still embeds installation logic and does not import the module.

- [ ] **T006 [P]** Add integration coverage for dual-mode runs
  - Files: `tests/integration/02-parameter-sets.Tests.ps1`
  - Work: Create an integration test that runs the script twice—once interactive with mocked host transcripts and once noninteractive with CLI parameters—asserting exit codes (0/2/3) and verifying artifacts written to a temporary path.
  - Depends on: T001
  - Blocks: T007–T011, T015, T017
  - Success: Test fails until the script honors both parameter sets and exit codes.

## Phase 3.3 – Core Implementation (after tests are red)
- [ ] **T007** Refactor module entrypoint for pure automation use
  - Files: `PSSpecKit/Public/Install-SpecKitTemplate.ps1`
  - Work: Remove inline `Read-Host` prompts, ensure the function relies solely on provided parameters, return structured errors instead of $false where appropriate, and surface metadata consumed by the script (e.g., detected collisions).
  - Depends on: T002, T003, T004, T005, T006
  - Blocks: T008, T010, T011
  - Success: Module exports a prompt-free `Install-SpecKitTemplate` function suitable for script delegation, and updated unit tests still fail until the script calls it.

- [ ] **T008** Delegate script logic to module and set up parameter-set scaffolding
  - Files: `tools/Install-SpecKitTemplate.ps1`
  - Work: Import `PSSpecKit.psm1` via `$PSScriptRoot`, remove duplicated download helpers, and centralize execution through the module while preserving parameter-set declarations from `data-model.md`.
  - Depends on: T007
  - Blocks: T009, T010, T011, T014
  - Success: Script compiles, tests still fail on interactive/TTY expectations, and module functions are invoked for install logic.

- [ ] **T009** Implement non-TTY guard for interactive parameter set
  - Files: `tools/Install-SpecKitTemplate.ps1`
  - Work: Add reusable `Test-TtyAvailable` guard (leveraging `$Host.UI.RawUI.KeyAvailable` with fallbacks). When `-Interactive` is requested without TTY support, emit descriptive messaging and exit code 2 before prompting.
  - Depends on: T008
  - Blocks: T010, T017
  - Success: Interactive tests still fail on prompt order but now observe the guard when run in non-TTY simulations.

- [ ] **T010** Build guided interactive prompt workflow
  - Files: `tools/Install-SpecKitTemplate.ps1`
  - Work: Implement the prompt sequence from `data-model.md` (header → Agent → Shell → Version → Path → collision confirmation → summary). Echo defaults when accepted, track decisions, and exit with code 3 when users decline overwrite or final confirmation.
  - Depends on: T008, T009
  - Blocks: T011, T015, T016
  - Success: Interactive tests begin to pass once noninteractive flow still pending.

- [ ] **T011** Finalize noninteractive execution and exit-code routing
  - Files: `tools/Install-SpecKitTemplate.ps1`
  - Work: Validate required parameters, pass values to the module, map module-returned errors to exit codes 0/1/3, and ensure `SaveZip`, `Retry`, and default path behaviors match `data-model.md`.
  - Depends on: T008, T010
  - Blocks: T012, T014, T015, T016, T017
  - Success: Unit and integration tests transition from red to green for parameter-set behavior.

## Phase 3.4 – Integration & Automation
- [ ] **T012** Add CI coverage for Pester + PSScriptAnalyzer on this feature
  - Files: `.github/workflows/pester-and-lint.yml`
  - Work: Create or update a workflow that runs `tools/run-pester-v5.ps1` and `Invoke-ScriptAnalyzer` against `tools/` and `PSSpecKit/` on pushes/PRs, capturing artifacts for exit-code assertions.
  - Depends on: T011
  - Blocks: T017
  - Success: CI workflow exists, references PowerShell 7, and fails until new tests pass.

## Phase 3.5 – Polish & Validation
- [ ] **T013 [P]** Update script comment-based help and examples
  - Files: `tools/Install-SpecKitTemplate.ps1`
  - Work: Refresh `.SYNOPSIS`, `.PARAMETER`, `.EXAMPLE`, and `.EXITCODES` sections to document two parameter sets, exit codes 0/1/2/3, and interactive vs noninteractive usage per contract.
  - Depends on: T011
  - Blocks: —
  - Success: Help text matches implemented behavior and passes script analyzer comment rules.

- [ ] **T014 [P]** Document quickstart scenarios with new flows
  - Files: `specs/feat/paramsets-install-speckit/quickstart.md`
  - Work: Update quickstart to show the header prompt transcript, overwrite confirmation options, noninteractive CLI sample with exit codes, and validation checklist aligned with final behavior.
  - Depends on: T011
  - Blocks: T016
  - Success: Quickstart instructions match the implemented script and integration tests.

- [ ] **T015 [P]** Refresh feature PR template notes
  - Files: `PR_BODY_feat-paramsets-install-speckit.md`
  - Work: Summarize new tests, CI workflow updates, and validation steps so reviewers have ready-to-use checklist items.
  - Depends on: T011
  - Blocks: —
  - Success: PR body contains sections for dual parameter-set validation and references new automated checks.

- [ ] **T016** Record manual validation results
  - Files: `specs/feat/paramsets-install-speckit/quickstart.md`
  - Work: After implementation, execute both flows manually (interactive defaults + CLI run) and append outcomes to the Validation Checklist with timestamps.
  - Depends on: T014
  - Blocks: —
  - Success: Quickstart validation checklist populated with real execution evidence.

- [ ] **T017** Run full quality gate and capture evidence
  - Files: `tests/`, `tools/run-pester-v5.ps1`, `.psscriptanalyzer.psd1`, `specs/feat/paramsets-install-speckit/quickstart.md`
  - Work: Execute `tools/run-pester-v5.ps1`, run `Invoke-ScriptAnalyzer` for `tools/` + `PSSpecKit/`, and note command outputs in the quickstart or PR body. Ensure CI workflow succeeds.
  - Depends on: T012, T013, T014, T015, T016
  - Blocks: —
  - Success: All automated checks and manual validation steps pass and are documented.

## Dependencies Summary
- T001 is prerequisite for all test authoring (T002–T006).
- Tests (T002–T006) must fail before starting implementation tasks T007–T011.
- Module refactor (T007) precedes any script changes (T008–T011).
- Script implementation (T008–T011) completes before CI/doc polish (T012–T017).
- Documentation and validation tasks (T014–T017) depend on working implementation and tests.

## Parallel Execution Examples
```
# Launch contract + argument + interactive tests together after T001:
#task run --id T002
#task run --id T003
#task run --id T004
#task run --id T005
#task run --id T006

# Run documentation polish concurrently once implementation is green:
#task run --id T013
#task run --id T014
#task run --id T015
```

Generated from `.specify/templates/tasks-template.md` for feature **ParameterSet enhancement for Install-SpecKitTemplate**.
