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
- **Compile-time Library Paths**: Automatically exposes `LIBRARY_PATH`, `C_INCLUDE_PATH`, `LD_LIBRARY_PATH`, and `PKG_CONFIG_PATH` from your `home.packages`, so plugins that compile from source (e.g. Python, Ruby) can find Nix-provided libraries
- **Container-friendly**: Optional `skipPluginSync` to avoid network calls at startup when plugins are pre-installed

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

### Container / CI Usage

In environments where plugins are pre-installed at build time (e.g. Docker), you can skip the plugin sync step to avoid network calls on every activation:

```nix
programs.asdf = {
  enable = true;
  skipPluginSync = true; # skip `asdf plugin add` and `asdf plugin update --all`

  nodejs = {
    enable = true;
    defaultVersion = "22.14.0";
  };
};
```

## Development

### Running Tests

Tests are Nix flake checks defined in `checks.nix`. Run all checks with:

```bash
nix flake check -L --keep-going
```

Or using [Task](https://taskfile.dev):

```bash
task test
```

Available checks:

- `disabled` - ASDF not enabled
- `withoutDirenv` - ASDF without direnv
- `withDirenv` - ASDF with direnv
- `withNodejs` - NodeJS plugin
- `withGolang` - Golang plugin
- `withTerraform` - Terraform plugin
- `withOpenTofu` - OpenTofu plugin
- `withRuby` - Ruby plugin
- `withPython` - Python plugin
- `withSkaffold` - Skaffold plugin
- `withKubectl` - Kubectl plugin
- `withKustomize` - Kustomize plugin
- `withMultiplePlugins` - Multiple plugins together

### CI Pipeline

The project uses GitHub Actions for continuous integration. The CI pipeline runs all checks on macOS and Ubuntu.

## Implementation Details

- Uses the official asdf-vm package from nixpkgs
- Installs plugins and tool versions during home-manager activation
- Manages plugin lifecycle (installation and removal)
- Generates configuration files (`.tool-versions`, `.default-*-packages`)
- Exposes compile-time library paths (`LIBRARY_PATH`, `C_INCLUDE_PATH`, etc.) from `home.packages`
- Includes direnv integration for project-specific environments

**NOTE**: Not all asdf plugins have declarative options, but the plugin install folder is not readonly so `asdf plugin add <name>` works normally.
