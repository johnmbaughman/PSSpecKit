Title: docs: constitution v1.0.1 — require PSScriptAnalyzer & clarify PowerShell best practices

Body:
Clarify Code Quality & Style to explicitly require PSScriptAnalyzer checks and adherence to Microsoft
PowerShell scripting best practices.

- Bump constitution version 1.0.0 → 1.0.1 (patch: clarifications).
- Update Sync Impact Report and Last Amended date (2025-10-02).
- Confirmed related specify templates align with the new gating rules.

Suggested follow-ups:
- Ensure CI installs and runs PSScriptAnalyzer (add to `.github/workflows/powershell-ci.yml` if missing).
- Optionally add a PSScriptAnalyzer baseline ruleset and wire into CI.

Files changed:
- .specify/memory/constitution.md

PR checklist:
- [ ] CI passes (Pester + PSScriptAnalyzer)
- [ ] Reviewers: at least two maintainers for non-breaking updates
- [ ] If adding PSScriptAnalyzer baseline, include ruleset path in PR
