# research.md

## Goal
Create a PowerShell-only script that downloads and prepares Spec Kit templates from the GitHub `spec-kit` releases.

## Decisions
- Use GitHub Releases API to locate assets (prefer releases list and asset names).
- Support optional `GITHUB_TOKEN` for higher rate limits; operate unauthenticated for public releases.
- Default behaviors (from clarifications):
  - Agent: auto-selected when omitted (AI/heuristic pick)
  - Shell: default `ps` (PowerShell)
  - Extraction path: current working directory, adjustable via `--path`
  - Extraction: skip existing files by default; `--force` to overwrite
  - Retry: 3 retries with exponential backoff (configurable via `--retry`)

## Risks
- GitHub API rate limits; mitigated by optional token usage and retry/backoff.
- Asset naming conventions might change; script uses pattern matching and will error clearly if no match.

## Acceptance criteria
- Script can locate and download the appropriate asset and extract it into a directory.
- Script respects `--path`, `--force`, `--shell`, and `--agent`.
- Script runs on PowerShell 7+ (best-effort on 5.1).
