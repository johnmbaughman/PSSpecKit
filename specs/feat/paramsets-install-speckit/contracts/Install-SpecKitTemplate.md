# Contract: Install-SpecKitTemplate.ps1 Parameter Sets

## Overview
Defines the callable surface for `tools/Install-SpecKitTemplate.ps1`, including parameter sets, prompt behaviour, and exit codes for automation consumers.

## Parameter Sets
### Noninteractive (default)
| Parameter | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `Agent` | `string` | Yes | n/a | Matches release asset agent identifiers. |
| `Shell` | `string` | Yes | n/a | Must be `ps` or `sh`. |
| `Version` | `string` | Yes | n/a | Release tag (e.g., `v1.2.0`) or `latest`. |
| `Path` | `string` | No | Current working directory | Destination folder for extracted template. |
| `Force` | `switch` | No | `False` | Bypasses overwrite prompt; mutually exclusive with `-Interactive`. |
| `SaveZip` | `switch` | No | Script default | Persist downloaded archive after extraction. |
| `Retry` | `int` | No | Script default | Number of retry attempts for download operations. |

### Interactive
| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `Interactive` | `switch` | Yes | Sole trigger for interactive flow; cannot be combined with noninteractive-only parameters. |

**Prompt sequence** (values stored in script context and echoed when defaults accepted):
1. Agent (default: previously used agent or project default).  
2. Shell (`ps` default).  
3. Version (`latest` default).  
4. Path (current working directory default).  
5. Overwrite confirmation if collisions detected (`Yes`, `No`, `Yes to all`, `No to all`).  
6. Final summary confirmation (`Yes`/`No`).

## Behavioural Guarantees
- `-Force` is rejected when supplied with `-Interactive` (binding failure → exit code 3).
- Using `-Interactive` in a non-TTY environment aborts before prompts with exit code 2 and descriptive error.
- Module functions are invoked via `Import-Module` from `$PSScriptRoot` to drive download/extract steps.
- All filesystem paths resolved relative to invocation context (no hard-coded absolutes).

## Exit Codes
| Code | Meaning | Consumer Action |
|------|---------|-----------------|
| 0 | Install succeeded. | Continue pipeline. |
| 1 | Unexpected failure (network, module errors, etc.). | Surface logs, retry or fail build. |
| 2 | Interactive requested but no TTY available. | Re-run noninteractively or adjust environment. |
| 3 | Validation failure or user cancelled overwrite/final confirmation. | Adjust parameters, confirm overwrites, or handle aborted run. |

## Examples
```powershell
# Interactive local run
pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 -Interactive

# Noninteractive CI run
pwsh -NoProfile -File tools/Install-SpecKitTemplate.ps1 `
    -Agent copilot -Shell ps -Version latest `
    -Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY `
    -Force -SaveZip -Retry 3
```
