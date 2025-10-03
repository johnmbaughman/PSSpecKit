Title: feat(paramsets): add Interactive and Noninteractive ParameterSets to Install-SpecKitTemplate

Summary

This PR implements the design and planning artifacts for adding two ParameterSets to `tools/Install-SpecKitTemplate.ps1`:
- `Interactive` parameter set: prompts for Agent, Shell, Version, Path, and Force when run in a TTY.
- `Noninteractive` parameter set: accepts all parameters explicitly for CI usage.

What changed (files added/updated)

- Added feature spec and artifacts under `specs/002-parameter-sets/`:
  - `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `tasks.md`
- Added feature copies under `specs/feat/paramsets-install-speckit/` for plan integration.
- Updated `tools/Install-SpecKitTemplate.ps1` (parameter-set plumbing and local edits present in branch).

Behavior & Acceptance

- Interactive runs will prompt only when targets exist or parameters are missing; SaveZip/Retry use defaults unless supplied.
- Running `-Interactive` in a non-TTY environment fails with exit code 2.
- Parameter-set validation is strict; incompatible parameter combinations fail with exit code 3.
- Overwrite confirmation uses a single prompt offering Yes/YesToAll/No/NoToAll; No aborts with exit code 3.

Testing

- This PR includes tasks and test plans under `specs/*` but does not yet add the final Pester test files. The next steps in tasks.md cover adding Pester tests and implementing code to satisfy them.

Notes

- The `gh` CLI is not available in the execution environment; opening the PR via the GitHub web UI is recommended. Use the auto-generated URL below or paste this body into the PR form.

Open PR URL

https://github.com/johnmbaughman/PSSpecKit/pull/new/feat/paramsets-install-speckit

Reviewer checklist

- [ ] Confirm spec and research artifacts align with implementation direction
- [ ] Review `tools/Install-SpecKitTemplate.ps1` parameter-set changes and validate no regressions
- [ ] Run the Pester tests once T002/T003 are implemented

