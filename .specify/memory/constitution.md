<!--
Sync Impact Report
Version change: none → 1.0.0
Modified principles:
- NEW: Code Quality & Style (PowerShell-centric)
- NEW: Testing Standards (Pester & CI gates)
- NEW: User Experience Consistency (cmdlet UX, help, output contracts)
- NEW: Performance Requirements (benchmarks, memory/latency goals)
Added sections:
- Development Constraints (PowerShell module rules, compatibility targets)
- Development Workflow (TDD, PR review checklist, PSScriptAnalyzer gating)
Removed sections: none
Templates requiring updates:
- .specify/templates/plan-template.md ✅ inspected (Constitution Check placeholder present; aligns with new principles)
- .specify/templates/spec-template.md ✅ inspected (requirements gating aligns)
- .specify/templates/tasks-template.md ✅ inspected (task rules align)
Follow-up TODOs:
- TODO(RATIFICATION_DATE): Confirm historical ratification date if this is not the first adoption (left as ratified today)
-->

# PSSpecKit Constitution

## Core Principles

### I. Code Quality & Style (PowerShell-centric)
All authored PowerShell code MUST follow Microsoft PowerShell best practices. This includes:
- Consistent, discoverable names following Verb-Noun cmdlet conventions (approved verbs from Microsoft). Module, function, and parameter names MUST be clear and purpose-driven.
- Script and module layout MUST follow common PowerShell module structure (ExportedFunctions, Public/Private separation, module manifest when applicable).
- Static analysis using PSScriptAnalyzer with a project baseline is REQUIRED; rules MAY be tightened per-module. Violations MUST be addressed before merging.
- Code MUST be idempotent where applicable and avoid implicit global state; side-effects MUST be explicit and documented.

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

**Version**: 1.0.0 | **Ratified**: 2025-10-01 | **Last Amended**: 2025-10-01