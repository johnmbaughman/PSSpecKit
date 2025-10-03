# Data Model – ParameterSet enhancement for Install-SpecKitTemplate

## Parameter Sets
| Name | Parameters | Mandatory | Notes |
|------|------------|-----------|-------|
| Interactive | `-Interactive` | Yes | Sole trigger for interactive experience; mutually exclusive with noninteractive arguments. |
|  | `Agent` (prompted) | Prompted | Accepts existing agent values; defaults to previous selection when available. |
|  | `Shell` (prompted) | Prompted | Choice constrained to `ps` / `sh`; defaults to `ps`. |
|  | `Version` (prompted) | Prompted | Defaults to `latest`; accepts semantic versions. |
|  | `Path` (prompted) | Prompted | Defaults to current working directory; echoed when accepted. |
| Noninteractive | `Agent` | Required | Explicit string; validated against release assets. |
|  | `Shell` | Required | `ps` or `sh`. |
|  | `Version` | Required | Release tag or `latest`. |
|  | `Path` | Optional | Defaults to current working directory if omitted. |
|  | `Force` | Optional | Enables overwrite without prompts; only valid in noninteractive set. |
|  | `SaveZip` | Optional | Boolean switch (default from script settings). |
|  | `Retry` | Optional | Int (default from script settings). |

## Prompt Flow (Interactive)
1. Display header summarizing upcoming prompts.  
2. Collect Agent → Shell → Version → Path (each with default shown; Enter accepts default and echoes selection).  
3. Detect collisions at target path; if any, present single confirmation including `Yes`, `No`, `Yes to all`, `No to all`.  
4. Present recap of chosen values and final `Proceed? (Yes/No)` confirmation.  
5. Abort with exit code 3 if user declines at overwrite or final confirmation stages.

## Exit Code Matrix
| Exit Code | Trigger | Consumer Guidance |
|-----------|---------|-------------------|
| 0 | Successful install run (interactive or noninteractive). | Downstream automation continues. |
| 1 | Unexpected/general failure (module import issues, network errors, etc.). | Surface error, retry or escalate. |
| 2 | Interactive mode requested without TTY support. | Inform caller the environment is noninteractive; rerun without `-Interactive`. |
| 3 | Parameter validation failure or user-declined overwrite/confirmation. | Adjust parameters or acknowledge abort in automation. |

## Module Interaction
- Script imports `PSSpecKit.psm1` via `$PSScriptRoot`-relative path.
- Core installation functions (download/extract) remain in the module; script focuses on UX orchestration.
- Shared utilities (logging, asset resolution) remain within `PSSpecKit/` and are invoked post-import.
