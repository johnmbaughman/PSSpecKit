# data-model.md — ParameterSet enhancement for Install-SpecKitTemplate

Date: 2025-10-02
Spec source: `C:\Personal\Files\source\repos\PSSpecKit\specs\feat\paramsets-install-speckit\spec.md`

## Entities

1. RunContext
   - id: string (UUID)
   - Timestamp: datetime
   - Mode: enum {Interactive, Noninteractive}
   - IsTty: boolean
   - ExitCode: integer

2. Parameters
   - Agent: string (required in Noninteractive or prompted in Interactive)
   - Shell: enum {ps, sh}
   - Version: string (tag or "latest")
   - Path: string (filesystem path)
   - Force: boolean
   - SaveZip: boolean (default: false)
   - Retry: integer (default: 0)

3. OverwriteDecision
   - Targets: array of string (paths)
   - Decision: enum {Yes, YesToAll, No, NoToAll}
   - Timestamp: datetime

## Relationships
- RunContext has one Parameters
- RunContext may have zero or one OverwriteDecision

## Validation Rules
- If Mode == Interactive, IsTty must be true else exit code 2
- If Mode == Noninteractive, no prompts allowed
- Retry must be >= 0
- Agent and Shell must be non-empty strings when required

## Notes
- Keep the data model small; it's primarily used to generate tests and structure code paths.
