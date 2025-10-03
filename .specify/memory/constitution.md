<!--
Sync Impact Report
Version change: 1.0.0 → 1.0.1
Modified principles:
- UPDATED: Code Quality & Style (explicit PSScriptAnalyzer enforcement & Microsoft PowerShell scripting best practices)
- NEW/CLARIFY: Testing Standards (Pester & CI gates clarified to include static analysis gating)
- NEW: User Experience Consistency (cmdlet UX, help, output contracts)
- NEW: Performance Requirements (benchmarks, memory/latency goals)
Added/clarified sections:
- Development Constraints (PowerShell module rules, compatibility targets)
- Development Workflow (TDD, PR review checklist, explicit PSScriptAnalyzer gating)
Removed sections: none
Templates requiring updates / inspection:
- .specify/templates/plan-template.md ✅ inspected (Constitution Check placeholder present; aligns with updated principles)
- .specify/templates/spec-template.md ✅ inspected (requirements gating aligns)
- .specify/templates/tasks-template.md ✅ inspected (task rules align)
Follow-up TODOs:
- None deferred. RATIFICATION_DATE retained as original adoption date.
-->

# PSSpecKit Constitution

## Core Principles

### I. Code Quality & Style (PowerShell-centric)
All authored PowerShell code MUST meet Microsoft PowerShell scripting best practices and pass the project's PSScriptAnalyzer quality checks. This is a mandatory, CI-enforced gate. Specifically:
- All code MUST adhere to Microsoft-approved naming conventions (Verb-Noun) and use discoverable, purpose-driven names for modules, functions and parameters.
- Script and module layouts MUST follow common PowerShell module structure (ExportedFunctions, Public/Private separation, and a module manifest when applicable).
- Static analysis using PSScriptAnalyzer against a project baseline configuration is REQUIRED; module-level rules MAY be tightened. CI MUST fail if PSScriptAnalyzer violations are present and violations MUST be addressed before merging.
- All scripts and modules MUST document any accepted deviations from the baseline (with rationale) in the PR; exceptions are time-limited and require maintainer approval.
- Code MUST be idempotent where applicable, avoid implicit global state, and make side-effects explicit and documented.

Path usage policy: NO absolute filesystem paths are permitted inside committed scripts or modules. All filesystem paths referenced by scripts MUST be relative to the script/module root and must be resolved at runtime using the script's location (for example, $PSScriptRoot) or a small, documented repository-root resolution helper called from the script root. Hard-coded absolute paths will fail review and MUST be removed before merge.

Rationale: Enforcing PowerShell-native patterns improves discoverability, reusability, and lowers the cognitive load for maintainers and users.

### II. Testing Standards (Pester & CI Gates) (NON-NEGOTIABLE)
- Tests MUST be written using Pester. Unit tests, integration tests, and contract tests MUST exist for public module functions and exposed behaviors.
- Test-First approach is REQUIRED for new features: write failing tests (Pester) before implementing behavior. Tests MUST be committed and fail on the main branch until implementation completes.
- Minimum coverage target: project-level baseline of 80% for new modules; exceptions MUST be approved in a PR with rationale and tracked in the issue.
- Continuous Integration MUST run Pester tests and PSScriptAnalyzer on each PR. PRs that fail CI MUST NOT be merged.

Rationale: Automated, repeatable testing prevents regressions, enables safe refactoring, and provides executable documentation for expected behavior.

### III. User Experience Consistency (Cmdlet UX & Output Contracts)
- Public-facing functions and cmdlets MUST provide consistent parameter names, parameter sets, and pipeline input where applicable.
- Every public function MUST include well-formed comment-based help (Synopsis, Description, Examples, Parameters, Outputs). Help MUST be validated in CI (e.g., example verification where feasible).
- Output objects SHOULD be strongly-typed (custom objects with documented properties) rather than free-form strings when consumed programmatically. When human-readable text is required, provide a --AsJson or equivalent switch for machine consumption.
- Errors MUST use standard PowerShell error types and include actionable messages. Use Write-Error, Throw, or ErrorRecord appropriately and document error codes when used across modules.

Rationale: Consistent UX reduces friction for script authors, enables composition via the pipeline, and supports automation at scale.

### IV. Performance Requirements and Benchmarks
- Performance goals MUST be defined for features that have measurable impact (e.g., cmdlet startup time, p95 latency for long-running operations, memory allocation targets). When unspecified, reasonable defaults apply: cmdlet cold-start under 200ms for small helpers; streaming operations maintain <200ms p95 per item when possible.
- Benchmarking harnesses (e.g., Pester-based performance tests or BenchmarkDotNet wrappers) MUST be added for performance-critical code. Performance regressions detected in CI MUST block merges until triaged.
- Avoid premature optimization; optimize based on measured regressions with PRs documenting the before/after metrics.

Rationale: Defining measurable performance targets prevents regressions and ensures the project remains usable in scripted/automation scenarios.

## Development Constraints (PowerShell compatibility & delivery)
- Target PowerShell versions: Modules SHOULD support PowerShell 7.x where feasible; compatibility shims for Windows PowerShell 5.1 MUST be documented if supported.
- Module packaging: Public modules MUST include a manifest (.psd1) with metadata and published to the project's chosen package feed following the project's release process.
- Security: Avoid storing secrets in code or logs; use SecretManagement/SecretStore or Key Vault integrations as the standard approach.

## Development Workflow, Review Process, and Quality Gates
- Development flow: TDD (Pester) → Implementation → Peer Review → CI (PSScriptAnalyzer + Pester + performance checks) → Merge.
- PR Requirements: Each PR MUST include linked issue/spec, tests that demonstrate the behavior, updated help/comments, and an automated CI pass. For changes that affect public surface area, add a compatibility note and, if breaking, a migration guide.
- Reviewers MUST verify adherence to Code Quality & Style and Testing Standards. Large or complex changes MAY require an experimental branch and staged rollout.

## Governance
The Constitution defines mandatory practices for development and review. Amendments follow the procedure below.

- Amendment Procedure: Propose an amendment as a PR against this file with rationale, tests (where applicable), and an impact analysis. A minor amendment (non-breaking clarification) requires two maintainer approvals. A major amendment (principle addition/removal or breaking governance change) requires consensus from the core maintainers and an explicitly documented migration plan.
- Versioning Policy: The Constitution uses semantic versioning: MAJOR for breaking governance changes (removals or redefinitions), MINOR for new principles or material expansions, PATCH for wording/clarity fixes. The author of the PR MUST indicate the expected bump and rationale.
- Compliance: The `Constitution Check` step in `.specify/templates/plan-template.md` and related templates MUST be evaluated during planning. CI tooling and reviewers are responsible for enforcing gates.

**Version**: 1.0.1 | **Ratified**: 2025-10-01 | **Last Amended**: 2025-10-02