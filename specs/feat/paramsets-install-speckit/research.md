# Research – ParameterSet enhancement for Install-SpecKitTemplate

## Decision 1: Parameter-set design
**Decision**: Define two explicit parameter sets (`Interactive`, `Noninteractive`) using `ParameterSetName` on each parameter, ensuring `-Interactive` is the lone switch in its set while all other parameters live in the noninteractive set.  
**Rationale**: Aligns with Microsoft guidance for mutually exclusive experiences—interactive flows rely on prompts, while automation requires full parameterization. This structure allows PowerShell’s binder to reject invalid combinations automatically (exit code 3 per spec).  
**Alternatives Considered**: 
- Single parameter set with optional `-Interactive`: rejected because it fails to prevent conflicting parameter usage and requires manual validation.  
- More than two parameter sets (e.g., `ForceInteractive`): rejected as unnecessary complexity without new user stories.

## Decision 2: Non-TTY detection & exit codes
**Decision**: Use `$Host.UI.RawUI.KeyAvailable` guard (with try/catch for hosts lacking RawUI) plus `$Host.Runspace?.OriginalHost?.UI?.SupportsVirtualTerminal` fallback to detect interactive capability. When unavailable, abort with exit code 2 as specified.  
**Rationale**: Works in PowerShell 7 across consoles and CI runners, allows clear error messaging before prompts begin, and keeps handling near the parameter-set binding logic.  
**Alternatives Considered**: 
- Relying solely on `$PSBoundParameters.ContainsKey('Interactive')`: rejected; doesn’t ensure TTY availability.  
- Using `Test-Interactive` community module: rejected to avoid external dependency.

## Decision 3: Module import pattern
**Decision**: Load shared functions via `Import-Module (Join-Path $PSScriptRoot '..' 'PSSpecKit' 'PSSpecKit.psm1') -Force -Scope Local` before executing install logic. Resolve paths with `$PSScriptRoot` to stay relative.  
**Rationale**: Upholds the constitution’s no-absolute-path rule, centralises shared logic, and keeps script updates minimal. `-Scope Local` avoids polluting caller sessions during interactive runs.  
**Alternatives Considered**: 
- Dot-sourcing `PSSpecKit.psm1`: rejected because dot-sourcing a module file bypasses manifest/config validation.  
- Copying module functions into the script: rejected as duplication and harder to maintain.
