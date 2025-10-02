# Quickstart: Spec Kit Downloader

## Examples

Default (auto-select agent, PowerShell templates to current directory):

pwsh tools\spec-kit-downloader.ps1

Specify agent and target path:

pwsh tools\spec-kit-downloader.ps1 -Agent myagent -Shell ps -Path ./templates

Force overwrite existing files:

pwsh tools\spec-kit-downloader.ps1 -Force

Use an explicit version tag:

pwsh tools\spec-kit-downloader.ps1 -Version v1.2.3

Using GITHUB_TOKEN for higher rate limits (Windows PowerShell example):

$env:GITHUB_TOKEN = 'ghp_...'
pwsh tools\spec-kit-downloader.ps1
