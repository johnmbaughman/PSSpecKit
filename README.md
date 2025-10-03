# PSSpecKit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

This repository contains tools for downloading and installing [GitHub Spec Kit](https://github.com/github/spec-kit) templates.

## Installation

The PSSpecKit module can be imported directly from the repository:

```powershell
Import-Module ./PSSpecKit/PSSpecKit.psd1
```

## Usage

Once imported, you can use the `Install-SpecKitTemplate` cmdlet:

```powershell
# Install the latest template to the current directory
Install-SpecKitTemplate

# Install a specific agent template
Install-SpecKitTemplate -Agent octo -Shell ps -Path ./templates -Force
```

For more examples and smoke tests, see `specs/001-create-a-powershell/quickstart.md`.

License
-------
This project is licensed under the MIT License — see the [LICENSE](./LICENSE) file for details.
