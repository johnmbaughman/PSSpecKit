# Tasks: Download Spec Kit Templates (PowerShell)# Tasks: Download Spec Kit Templates (PowerShell)



**Input**: `specs/001-create-a-powershell/spec.md`**Input**: `specs/001-create-a-powershell/spec.md`

**Feature Branch**: `001-create-a-powershell`**Feature Branch**: `001-create-a-powershell`



## Tasks (T001...)## Execution Flow

1. Setup project artifacts and linting

T001 Setup: Script file and quickstart

```markdown
# Tasks: Download Spec Kit Templates (PowerShell)

Input: `specs/001-create-a-powershell/spec.md`
Feature branch: `001-create-a-powershell`

Feature directory: `specs/001-create-a-powershell`

Available docs found: `research.md`, `data-model.md`, `quickstart.md`

Follow these executable tasks in order. Tasks prefixed with [P] can be executed in parallel when they touch different files. Each task includes file paths and expected outputs so an LLM or a developer can complete it directly.

T001 Setup: Project skeleton and linting (required)
- Title: Create script skeleton, repo metadata, and quickstart
- Files to create/update:
  - `tools/spec-kit-downloader.ps1` (script entrypoint - ensure comment-based help present)
  - `specs/001-create-a-powershell/quickstart.md` (usage examples)
  - `.psscriptanalyzer.psd1` (rules - already present)
  - `.gitattributes` (already present)
- Success criteria: files exist, script has param block and comment-based help, quickstart contains example runs.

T002 [P] Tests (unit) - Argument parsing and defaults
- Title: Add unit tests for parameter parsing and defaults
- Files to create:
  - `tests/SpecKitDownloader.Args.Tests.ps1`
- Description: Write Pester tests that dot-source `tools/spec-kit-downloader.ps1` and assert default values for `Shell`, `Version`, `Retry`, and that the param block accepts `Agent`, `Force`, `Path`, and `Interactive`.
- Dependency: T001
- Success criteria: tests fail initially (TDD), then pass after implementation.

T003 [P] Tests (unit) - Asset selection logic
- Title: Add tests to verify asset matching and fallback behavior
- Files to create:
  - `tests/SpecKitDownloader.AssetSelection.Tests.ps1`
- Description: Mock GitHub release JSON and assert `Find-ReleaseAsset` chooses the correct `spec-kit-template-[agent]-[ps|sh]-v[version].zip` asset. Include fallback behavior when agent omitted.
- Dependency: T001
- Success criteria: tests express expected behavior; initial fail is OK (TDD).

T004 Core: Implement release discovery & asset selection (Get-LatestReleaseTag, Find-ReleaseAsset)
- Title: Implement release lookup and asset selection
- Files to modify:
  - `tools/spec-kit-downloader.ps1`
- Description: Implement `Get-LatestReleaseTag` to query GitHub API (use `GITHUB_TOKEN` if present). Implement `Find-ReleaseAsset` to match the naming pattern and respect `Shell` and `Agent`.
- Dependency: T001, T002, T003
- Success criteria: Unit tests in T002/T003 pass.

T005 Core: Implement download + retry helper (Download-Asset, Invoke-WithRetry)
- Title: Implement downloading and retry logic
- Files to modify:
  - `tools/spec-kit-downloader.ps1`
- Description: Implement `Download-Asset` using `Invoke-WebRequest` or `Invoke-RestMethod`, honor `GITHUB_TOKEN` via Authorization header, and implement exponential backoff controlled by `Retry` param.
- Dependency: T004
- Success criteria: tests (unit/integration) can simulate download and observe retry behavior.

T006 Core: Implement ZIP validation and safe extraction (Validate-Zip, Safe-Extract)
- Title: Implement ZIP validation and safe extract logic
- Files to modify:
  - `tools/spec-kit-downloader.ps1`
- Description: Implement `Validate-Zip` to open zip with `System.IO.Compression.ZipFile` and implement `Safe-Extract` to extract to temp folder and move files to target, skipping existing files unless `--Force` used.
- Dependency: T005
- Success criteria: `tests/SpecKitDownloader.Tests.ps1` passes and extraction handles existing files correctly.

T007 Core: Agent auto-selection and interactive mode
- Title: Implement agent auto-selection heuristics and `--Interactive`
- Files to modify:
  - `tools/spec-kit-downloader.ps1`
- Description: When `--Agent` omitted, infer candidates from release assets/meta and choose a sensible default; if multiple candidates and `--Interactive` specified, prompt the user.
- Dependency: T004, T006
- Success criteria: Tests for asset selection and interactive flow pass.

T008 [P] Tests (integration) - Download & extract (dry-run)
- Title: Add an integration test that runs the full flow against a sample zip
- Files to create:
  - `tests/integration/01-download-integration.Tests.ps1`
- Description: Use `tests/create-sample-zip.ps1` and stub/mock network calls (or use recorded responses) to run script end-to-end and assert files extracted to `--Path`.
- Dependency: T006, T007
- Success criteria: Integration test passes in CI.

T009 Logging, exit codes, and help polish
- Title: Add structured logging, exit codes, and update comment-based help
- Files to modify:
  - `tools/spec-kit-downloader.ps1`
  - `specs/001-create-a-powershell/quickstart.md`
- Description: Ensure `Write-Log` outputs consistent levels, define exit codes (0 success, 1 generic failure, 2 network, 3 asset not found, 4 auth), and verify examples in quickstart reflect behavior.
- Dependency: T006
- Success criteria: Help and quickstart updated; script returns defined exit codes for simulated failure modes.

T010 CI: Add/verify GitHub Actions workflow for linting and tests
- Title: Ensure CI runs PSScriptAnalyzer and Pester on PRs
- Files: `.github/workflows/powershell-ci.yml` (already added)
- Description: Ensure workflow runs for `001-create-a-powershell` and `v1_specsdev`; adjust as needed.
- Dependency: T001-T009
- Success criteria: CI succeeds (or shows actionable findings) on PR.

T011 Docs & Quickstart polish
- Title: Finalize `specs/001-create-a-powershell/quickstart.md` and update repo README
- Files to modify:
  - `specs/001-create-a-powershell/quickstart.md`
  - `README.md` (optional)
- Description: Add copyable examples and smoke-test steps (see T012 below).
- Dependency: T009
- Success criteria: Quickstart provides 3 example runs with expected results.

T012 Manual verification & smoke tests
- Title: Run smoke tests locally
- Steps (document in quickstart and run manually):
  1. Create a temp directory and run: `pwsh tools/spec-kit-downloader.ps1`
  2. Run: `pwsh tools/spec-kit-downloader.ps1 --shell sh --path ./tmp --force`
  3. Verify exit codes and presence of expected files
- Dependency: T008-T011
- Success criteria: Smoke test passes and documented in quickstart.

T013 Release / PR prep
- Title: Prepare PR with artifacts
- Files to include in PR: script, tests, quickstart, CI workflow, analyzer config
- Description: Open PR from `001-create-a-powershell` → `v1_specsdev` (or `main` per repo policy). Include list of clarifications and test results in PR description.
- Dependency: All previous tasks

Parallel execution guidance
- The following tasks are safe to run in parallel (they create separate test files or operate on separate paths): T002, T003, T008.
- Linting (T001/T010) and tests (T002/T003/T008) can be executed in parallel in CI.

How to run locally (quick commands)
```powershell
# Run unit tests (from repo root)
pwsh -NoProfile -c "Import-Module Pester; Invoke-Pester -Script tests -EnableExit"

# Run script (smoke test) from repo root
pwsh -NoProfile -c "pwsh tools/spec-kit-downloader.ps1 --Path (Get-Location)"
```

---

Generated by `/tasks` for feature: Download Spec Kit Templates (PowerShell)

```
  - `..\.psscriptanalyzer.psd1` (rules - already present)
  - `..\.gitattributes` (already present)
- Success criteria: files exist, script has param block and comment-based help, quickstart contains example runs.

T002 [P] Tests (unit) - Argument parsing and defaults
- Title: Add unit tests for parameter parsing and defaults
- Files to create:
  - `..\tests\SpecKitDownloader.Args.Tests.ps1`
- Description: Write Pester tests that dot-source `tools\spec-kit-downloader.ps1` and assert default values for `Shell`, `Version`, `Retry`, and that the param block accepts `Agent`, `Force`, `Path`, and `Interactive`.
- Dependency: T001
- Success criteria: tests fail initially (TDD), then pass after implementation.

T003 [P] Tests (unit) - Asset selection logic
- Title: Add tests to verify asset matching and fallback behavior
- Files to create:
  - `..\tests\SpecKitDownloader.AssetSelection.Tests.ps1`
- Description: Mock GitHub release JSON and assert `Find-ReleaseAsset` chooses the correct `spec-kit-template-[agent]-[ps|sh]-v[version].zip` asset. Include fallback behavior when agent omitted.
- Dependency: T001
- Success criteria: tests express expected behavior; initial fail is OK (TDD).

T004 Core: Implement release discovery & asset selection (Get-LatestReleaseTag, Find-ReleaseAsset)
- Title: Implement release lookup and asset selection
- Files to modify:
  - `..\tools\spec-kit-downloader.ps1`
- Description: Implement `Get-LatestReleaseTag` to query GitHub API (use `GITHUB_TOKEN` if present). Implement `Find-ReleaseAsset` to match the naming pattern and respect `Shell` and `Agent`.
- Dependency: T001, T002, T003
- Success criteria: Unit tests in T002/T003 pass.

T005 Core: Implement download + retry helper (Download-Asset, Invoke-WithRetry)
- Title: Implement downloading and retry logic
- Files to modify:
  - `..\tools\spec-kit-downloader.ps1`
- Description: Implement `Download-Asset` using `Invoke-WebRequest` or `Invoke-RestMethod`, honor `GITHUB_TOKEN` via Authorization header, and implement exponential backoff controlled by `Retry` param.
- Dependency: T004
- Success criteria: tests (unit/integration) can simulate download and observe retry behavior.

T006 Core: Implement ZIP validation and safe extraction (Validate-Zip, Safe-Extract)
- Title: Implement ZIP validation and safe extract logic
- Files to modify:
  - `..\tools\spec-kit-downloader.ps1`
- Description: Implement `Validate-Zip` to open zip with `System.IO.Compression.ZipFile` and implement `Safe-Extract` to extract to temp folder and move files to target, skipping existing files unless `--Force` used.
- Dependency: T005
- Success criteria: `tests/SpecKitDownloader.Tests.ps1` passes and extraction handles existing files correctly.

T007 Core: Agent auto-selection and interactive mode
- Title: Implement agent auto-selection heuristics and `--Interactive`
- Files to modify:
  - `..\tools\spec-kit-downloader.ps1`
- Description: When `--Agent` omitted, infer candidates from release assets/meta and choose a sensible default; if multiple candidates and `--Interactive` specified, prompt the user.
- Dependency: T004, T006
- Success criteria: Tests for asset selection and interactive flow pass.

T008 [P] Tests (integration) - Download & extract (dry-run)
- Title: Add an integration test that runs the full flow against a sample zip
- Files to create:
  - `..\tests\integration\01-download-integration.Tests.ps1`
- Description: Use `tests/create-sample-zip.ps1` and stub/mock network calls (or use recorded responses) to run script end-to-end and assert files extracted to `--Path`.
- Dependency: T006, T007
- Success criteria: Integration test passes in CI.

T009 Logging, exit codes, and help polish
- Title: Add structured logging, exit codes, and update comment-based help
- Files to modify:
  - `..\tools\spec-kit-downloader.ps1`
  - `..\specs\001-create-a-powershell\quickstart.md`
- Description: Ensure `Write-Log` outputs consistent levels, define exit codes (0 success, 1 generic failure, 2 network, 3 asset not found, 4 auth), and verify examples in quickstart reflect behavior.
- Dependency: T006
- Success criteria: Help and quickstart updated; script returns defined exit codes for simulated failure modes.

T010 CI: Add/verify GitHub Actions workflow for linting and tests
- Title: Ensure CI runs PSScriptAnalyzer and Pester on PRs
- Files: `.github/workflows/powershell-ci.yml` (already added)
- Description: Ensure workflow runs for `001-create-a-powershell` and `v1_specsdev`; adjust as needed.
- Dependency: T001-T009
- Success criteria: CI succeeds (or shows actionable findings) on PR.

T011 Docs & Quickstart polish
- Title: Finalize `quickstart.md` and update repo README
- Files to modify:
  - `..\specs\001-create-a-powershell\quickstart.md`
  - `..\README.md` (optional)
- Description: Add copyable examples and smoke-test steps (see T013 below).
- Dependency: T009
- Success criteria: Quickstart provides 3 example runs with expected results.

T012 Manual verification & smoke tests
- Title: Run smoke tests locally
- Steps (document in quickstart and run manually):
  1. Create a temp directory and run: `pwsh tools\spec-kit-downloader.ps1`
  2. Run: `pwsh tools\spec-kit-downloader.ps1 --shell sh --path ./tmp --force`
  3. Verify exit codes and presence of expected files
- Dependency: T008-T011
- Success criteria: Smoke test passes and documented in quickstart.

T013 Release / PR prep
- Title: Prepare PR with artifacts
- Files to include in PR: script, tests, quickstart, CI workflow, analyzer config
- Description: Open PR from `001-create-a-powershell` → `v1_specsdev` (or `main` per repo policy). Include list of clarifications and test results in PR description.
- Dependency: All previous tasks

Parallel execution guidance
- The following tasks are safe to run in parallel (they create separate test files or operate on separate paths): T002, T003, T008.
- Linting (T001/T010) and tests (T002/T003/T008) can be executed in parallel in CI.

How to run locally (quick commands)
```powershell
# Run unit tests
pwsh -NoProfile -c "Import-Module Pester; Invoke-Pester -Script .\tests -EnableExit"

# Run script (smoke test)
pwsh -NoProfile -c "pwsh tools\spec-kit-downloader.ps1 --Path (Get-Location)"
```

---

Generated by `/tasks` for feature: Download Spec Kit Templates (PowerShell)

```
