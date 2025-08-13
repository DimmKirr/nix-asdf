# Nix Home Manager module for ASDF

## Status
Work in progress that fits my current use case

## What
A way to configure asdf using NIX and home-manager.

## Why
For times when working on projects that have not fully embraced NIX.

## Features

### Supported Plugins
The following plugins are currently supported with declarative configuration:

- NodeJS (with default packages support)
- Ruby (with default packages support)
- Python (with default packages support)
- Terraform
- OpenTofu
- Golang
- Skaffold
- Kubectl
- Kustomize

### Key Benefits

- **Declarative Configuration**: Define your development environment in code
- **Version Consistency**: Ensure consistent tool versions across your team
- **Integration with Home Manager**: Seamlessly works with your existing Nix setup
- **Default Packages**: Automatically install default packages for supported languages
- **Tool Versions**: Automatically generates `.tool-versions` file based on your configuration

### Example Configuration

```nix
programs.asdf = {
  enable = true;
  
  nodejs = {
    enable = true;
    defaultVersion = "22.14.0";
    defaultPackages = [
      "yarn"
      "pnpm"
    ];
  };
  
  golang = {
    enable = true;
    defaultVersion = "1.24.3";
  };
  
  ruby = {
    enable = true;
    defaultVersion = "3.4.2";
  };
};
```

## Development

### Running Tests

This project uses [Task](https://taskfile.dev) to run tests locally. To run all tests:

```bash
# Install Task if you don't have it
brew install go-task

# Run all tests
task check:all

# Run a specific test
task check:withGolang
```

Available test tasks:

- `check:all` - Run all checks
- `check:disabled` - Test with ASDF disabled
- `check:withoutDirenv` - Test ASDF without direnv
- `check:withDirenv` - Test ASDF with direnv
- `check:withNodejs` - Test NodeJS plugin
- `check:withGolang` - Test Golang plugin
- `check:withTerraform` - Test Terraform plugin
- `check:withOpenTofu` - Test OpenTofu plugin
- `check:withRuby` - Test Ruby plugin
- `check:withPython` - Test Python plugin
- `check:withMultiplePlugins` - Test multiple plugins together

### CI Pipeline

The project uses GitHub Actions for continuous integration. The CI pipeline runs all tests on macOS to ensure compatibility.

## Implementation Details

- Uses the official asdf-vm package from nixpkgs
- Installs plugins and tool versions during home-manager activation
- Manages plugin lifecycle (installation and removal)
- Generates configuration files (.tool-versions, .default-*-packages)
- Includes direnv integration for project-specific environments

**NOTE**
Not all plugins are currently included but the plugin install folder is not readonly so normal ASDF plugin install should work
