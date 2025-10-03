# Implementation Plan: ParameterSet enhancement for Install-SpecKitTemplate

**Branch**: `feat/paramsets-install-speckit` | **Date**: 2025-10-02 | **Spec**: [`specs/feat/paramsets-install-speckit/spec.md`](./spec.md)
**Input**: Feature specification from `specs/feat/paramsets-install-speckit/spec.md`

## Summary
Enable `tools/Install-SpecKitTemplate.ps1` to provide a guided interactive workflow while preserving a fully parameterized, automation-friendly path. Two parameter sets (`Interactive`, `Noninteractive`) will orchestrate prompts, validation, and module-backed install logic so local users get confirmations and defaults, and CI can pass explicit arguments on the command line.

## Technical Context
**Language/Version**: PowerShell 7.x (Core-compatible)  
**Primary Dependencies**: PSSpecKit module (`PSSpecKit.psm1`), Pester v5, PSScriptAnalyzer baseline rules  
**Storage**: N/A (filesystem operations scoped to user-selected paths)  
**Testing**: Pester v5 suites (`tests/Install-SpecKitTemplate*.Tests.ps1`, `tests/integration/`)  
**Target Platform**: PowerShell 7+ shells on Windows/macOS/Linux (TTY + non-TTY consideration)  
**Project Type**: Single project (PowerShell module + supporting scripts)  
**Performance Goals**: Script startup and prompt handling under 200ms cold start (Constitution default for helpers)  
**Constraints**: Must pass PSScriptAnalyzer, follow Verb-Noun naming, avoid absolute paths, handle non-TTY failures explicitly  
**Scale/Scope**: Single installer script with interactive prompts plus noninteractive automation usage

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*
1. **Code Quality & Style**: Plan enforces Verb-Noun naming, module import via `$PSScriptRoot`, and keeps all filesystem paths relative. PSScriptAnalyzer checks run locally and in CI.
2. **Testing Standards**: Failing Pester tests will be authored for new parameter sets and exit-code behavior before implementation; CI workflow includes Pester + PSScriptAnalyzer gates.
3. **User Experience Consistency**: Interactive prompts mirror cmdlet UX with comment-based help, consistent parameter sets, and actionable errors for invalid combinations.
4. **Performance Requirements**: Interactive path reuses module logic and short-lived prompts, keeping cold start latency within the 200ms budget.

**Gate Result**: PASS (no violations identified)

## Project Structure

### Documentation (this feature)
```
specs/feat/paramsets-install-speckit/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    └── Install-SpecKitTemplate.md
```

### Source Code (repository root)
```
PSSpecKit/
├── Public/
├── Private/
├── PSSpecKit.psm1
└── PSSpecKit.psd1

tools/
├── Install-SpecKitTemplate.ps1
├── run-pester-v5.ps1
├── spec-kit-downloader.ps1
└── debug-interactive-single.ps1

tests/
├── Install-SpecKitTemplate.Tests.ps1
├── Install-SpecKitTemplate.Args.Tests.ps1
├── Install-SpecKitTemplate.Interactive.Tests.ps1
├── Install-SpecKitTemplate.AssetSelection.Tests.ps1
└── integration/

.github/workflows/
└── (Pester + PSScriptAnalyzer CI pipeline to be added for this feature)
```

**Structure Decision**: Single-project PowerShell module with supporting tooling. Feature work touches `tools/Install-SpecKitTemplate.ps1`, helper functions in `PSSpecKit/`, Pester suites in `tests/`, and CI automation under `.github/workflows/`.

## Phase 0: Outline & Research
1. **Unknowns to resolve**
   - PowerShell parameter-set guidance for dual interactive/noninteractive experiences.
   - Reliable non-TTY detection and exit-code conventions in PowerShell 7.
   - Importing sibling modules from scripts without absolute paths.

2. **Research tasks**
   ```
   Task: "Research PowerShell parameter-set standards for dual interactive/noninteractive workflows"
   Task: "Investigate reliable non-TTY detection patterns and exit-code usage in pwsh"
   Task: "Document best practices for importing sibling modules from scripts using $PSScriptRoot"
   ```

3. **Research deliverable**
   - Summarize each decision with rationale and alternatives in `research.md`, linking findings to functional requirements and constitutional gates.

**Output**: `research.md` capturing decisions and references for the three focus areas.

## Phase 1: Design & Contracts
*Prerequisite: `research.md` complete*

1. **Entities → `data-model.md`**
   - Parameter sets (`Interactive`, `Noninteractive`) with parameter membership, mandatory flags, and validation rules.
   - Prompt flow describing defaults, confirmation prompts, and summary confirmation.
   - Exit-code matrix documenting triggers for codes 1, 2, and 3.

2. **Contracts → `/contracts/Install-SpecKitTemplate.md`**
   - Document invocation contracts for both parameter sets (required/optional parameters, examples).
   - Capture prompt sequences, overwrite confirmation with "Yes to all/No to all", and final summary confirmation.
   - Include non-TTY failure contract and expected exit codes.

3. **Tests (failing initially)**
   - Extend existing `tests/Install-SpecKitTemplate*.Tests.ps1` files with new `Describe` blocks for parameter binding, prompt defaults, non-TTY detection, and module import usage.
   - Guard tests with `Pending` notes only if implementation blocking research remains (expected none after Phase 0).

4. **User scenarios → `quickstart.md`**
   - Step-by-step flows for interactive use (default acceptance, overwrite denial/approval).
   - Noninteractive CI example using fully parameterized command.
   - Validation checklist referencing exit codes and expected files on disk.

5. **Agent context update**
   - Run `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot` to record new dependencies (dual parameter-set pattern, non-TTY guard, module import rule) while preserving existing context.

**Output**: `data-model.md`, `/contracts/Install-SpecKitTemplate.md`, updated failing Pester specs, `quickstart.md`, refreshed agent context file.

## Phase 2: Task Planning Approach
*Executed by `/tasks`; included here for traceability.*

**Task Generation Strategy**
- Load `.specify/templates/tasks-template.md` as baseline.
- Derive tasks from Phase 1 artifacts:
  - Contracts → failing test updates (mark `[P]` when independent).
  - Data model → implementation/refactor tasks for script and module.
  - Quickstart → documentation and manual validation tasks.
- Ensure CI workflow additions and documentation updates are explicitly captured.

**Ordering Strategy**
- Begin with TDD: add failing Pester tests (Args, Interactive, integration).
- Follow with module import refactor and parameter-set enforcement in the script.
- Finish with CI workflow additions, comment-based help updates, and quickstart verification (docs/ops tasks `[P]`).

**Estimated Output**: 20-25 ordered tasks in `tasks.md`, balancing parallel documentation efforts with sequential code/test work.

## Phase 3+: Future Implementation
*Beyond `/plan`; listed for completeness*

- **Phase 3**: `/tasks` command generates `tasks.md`.
- **Phase 4**: Implement tasks (tests first, then script/module updates, finally docs/CI).
- **Phase 5**: Validation (Pester suites, PSScriptAnalyzer, quickstart manual run, CI workflow pass).

## Complexity Tracking
| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _None_ | n/a | n/a |

## Progress Tracking
**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v1.0.1 – see `.specify/memory/constitution.md`*
