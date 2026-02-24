{ lib, self, darwin, system, home-manager, nixpkgs }:
let
  isDarwin = lib.strings.hasSuffix "darwin" system;
  pkgs = import nixpkgs { inherit system; };

  # Helper to create a check that works on both Darwin and Linux
  mkCheck = name: hmConfig: assertions:
    if isDarwin then
      (darwin.lib.darwinSystem {
        inherit system;
        modules = [
          home-manager.darwinModules.home-manager
          ({ config, pkgs, lib, ... }: {
            system.stateVersion = 6;
            users.users.test.home = "/Users/test";
            home-manager.useGlobalPkgs = true;
            home-manager.sharedModules = [ self.homeManagerModules.default ];
            home-manager.users.test = {
              home.stateVersion = "25.11";
            } // hmConfig;
            assertions = map (a: a config.home-manager.users.test) assertions;
          })
        ];
      }).system
    else
      (home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          self.homeManagerModules.default
          ({ config, pkgs, lib, ... }: {
            home.username = "test";
            home.homeDirectory = "/home/test";
            home.stateVersion = "25.11";
            assertions = map (a: a config) assertions;
          } // hmConfig)
        ];
      }).activationPackage;

  # Assertion helpers that work with both Darwin and Linux config structures
  hasPackage = package: config:
    let
      packages = config.home.packages or [];
    in
    lib.lists.any (x: x ? pname && x.pname == package) packages;

  hasPlugin = plugin: config:
    lib.elem plugin (config.programs.asdf.plugins or []);

  hasToolVersion = tool: version: config:
    let
      toolVersionsFile = config.home.file.".tool-versions".text or "";
    in
    lib.strings.hasInfix "${tool} ${version}" toolVersionsFile;

  hasDefaultPackages = file: package: config:
    let
      content = config.home.file.${file}.text or "";
    in
    lib.strings.hasInfix package content;

in
{
  disabled = mkCheck "disabled" {
    # ASDF not enabled
  } [
    (config: {
      assertion = !(hasPackage "asdf-vm" config);
      message = "ASDF should not be included as a package when disabled";
    })
  ];

  withoutDirenv = mkCheck "withoutDirenv" {
    programs.asdf = {
      enable = true;
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = !(config.programs.direnv.enable or false);
      message = "Direnv should be disabled when not configured";
    })
  ];

  withDirenv = mkCheck "withDirenv" {
    programs.asdf = {
      enable = true;
      direnv.enable = true;
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = config.programs.direnv.enable or false;
      message = "Direnv should be enabled";
    })
    (config: {
      assertion = lib.strings.hasInfix "asdf" (config.programs.direnv.stdlib or "");
      message = "Direnv should be configured for ASDF";
    })
  ];

  withNodejs = mkCheck "withNodejs" {
    programs.asdf = {
      enable = true;
      nodejs = {
        enable = true;
        defaultVersion = "22.14.0";
        defaultPackages = [ "yarn" ];
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "nodejs" config;
      message = "NodeJS plugin should be enabled";
    })
    (config: {
      assertion = hasToolVersion "nodejs" "22.14.0" config;
      message = "NodeJS version should be set in .tool-versions";
    })
    (config: {
      assertion = hasDefaultPackages ".default-npm-packages" "yarn" config;
      message = "NodeJS default packages should be set";
    })
  ];

  withGolang = mkCheck "withGolang" {
    programs.asdf = {
      enable = true;
      golang = {
        enable = true;
        defaultVersion = "1.24.3";
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "golang" config;
      message = "Golang plugin should be enabled";
    })
    (config: {
      assertion = hasToolVersion "golang" "1.24.3" config;
      message = "Golang version should be set in .tool-versions";
    })
  ];

  withTerraform = mkCheck "withTerraform" {
    programs.asdf = {
      enable = true;
      terraform = {
        enable = true;
        defaultVersion = "1.5.5";
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "terraform" config;
      message = "Terraform plugin should be enabled";
    })
    (config: {
      assertion = hasToolVersion "terraform" "1.5.5" config;
      message = "Terraform version should be set in .tool-versions";
    })
  ];

  withOpenTofu = mkCheck "withOpenTofu" {
    programs.asdf = {
      enable = true;
      opentofu = {
        enable = true;
        defaultVersion = "1.9.0";
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "opentofu" config;
      message = "OpenTofu plugin should be enabled";
    })
    (config: {
      assertion = hasToolVersion "opentofu" "1.9.0" config;
      message = "OpenTofu version should be set in .tool-versions";
    })
  ];

  withRuby = mkCheck "withRuby" {
    programs.asdf = {
      enable = true;
      ruby = {
        enable = true;
        defaultVersion = "3.4.2";
        defaultPackages = [ "bundler" "pry" ];
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "ruby" config;
      message = "Ruby plugin should be enabled";
    })
    (config: {
      assertion = hasToolVersion "ruby" "3.4.2" config;
      message = "Ruby version should be set in .tool-versions";
    })
    (config: {
      assertion = hasDefaultPackages ".default-ruby-packages" "bundler" config;
      message = "Ruby default packages should be set";
    })
  ];

  withPython = mkCheck "withPython" {
    programs.asdf = {
      enable = true;
      python = {
        enable = true;
        defaultVersion = "3.13.2";
        defaultPackages = [ "pip" "pytest" ];
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "python" config;
      message = "Python plugin should be enabled";
    })
    (config: {
      assertion = hasToolVersion "python" "3.13.2" config;
      message = "Python version should be set in .tool-versions";
    })
    (config: {
      assertion = hasDefaultPackages ".default-python-packages" "pip" config;
      message = "Python default packages should be set";
    })
  ];

  withSkaffold = mkCheck "withSkaffold" {
    programs.asdf = {
      enable = true;
      skaffold.enable = true;
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "skaffold" config;
      message = "Skaffold plugin should be enabled";
    })
  ];

  withKubectl = mkCheck "withKubectl" {
    programs.asdf = {
      enable = true;
      kubectl.enable = true;
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "kubectl" config;
      message = "Kubectl plugin should be enabled";
    })
  ];

  withKustomize = mkCheck "withKustomize" {
    programs.asdf = {
      enable = true;
      kustomize.enable = true;
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "kustomize" config;
      message = "Kustomize plugin should be enabled";
    })
  ];

  withMultiplePlugins = mkCheck "withMultiplePlugins" {
    programs.asdf = {
      enable = true;
      direnv.enable = true;
      nodejs = {
        enable = true;
        defaultVersion = "22.14.0";
        defaultPackages = [ "yarn" ];
      };
      golang = {
        enable = true;
        defaultVersion = "1.24.3";
      };
      ruby = {
        enable = true;
        defaultVersion = "3.4.2";
      };
      python = {
        enable = true;
        defaultVersion = "3.13.2";
      };
      terraform = {
        enable = true;
        defaultVersion = "1.5.5";
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "nodejs" config;
      message = "NodeJS plugin should be enabled";
    })
    (config: {
      assertion = hasPlugin "golang" config;
      message = "Golang plugin should be enabled";
    })
    (config: {
      assertion = hasPlugin "ruby" config;
      message = "Ruby plugin should be enabled";
    })
    (config: {
      assertion = hasPlugin "python" config;
      message = "Python plugin should be enabled";
    })
    (config: {
      assertion = hasPlugin "terraform" config;
      message = "Terraform plugin should be enabled";
    })
    (config: {
      assertion = hasToolVersion "nodejs" "22.14.0" config;
      message = "NodeJS version should be set in .tool-versions";
    })
    (config: {
      assertion = hasToolVersion "golang" "1.24.3" config;
      message = "Golang version should be set in .tool-versions";
    })
    (config: {
      assertion = hasToolVersion "ruby" "3.4.2" config;
      message = "Ruby version should be set in .tool-versions";
    })
    (config: {
      assertion = hasToolVersion "python" "3.13.2" config;
      message = "Python version should be set in .tool-versions";
    })
    (config: {
      assertion = hasToolVersion "terraform" "1.5.5" config;
      message = "Terraform version should be set in .tool-versions";
    })
  ];

  withSkipPluginSync = mkCheck "withSkipPluginSync" {
    programs.asdf = {
      enable = true;
      skipPluginSync = true;
      nodejs = {
        enable = true;
        defaultVersion = "22.14.0";
      };
    };
  } [
    (config: {
      assertion = hasPackage "asdf-vm" config;
      message = "ASDF should be included as a package";
    })
    (config: {
      assertion = hasPlugin "nodejs" config;
      message = "NodeJS plugin should still be in the plugins list";
    })
    (config: {
      assertion = hasToolVersion "nodejs" "22.14.0" config;
      message = "NodeJS version should still be in .tool-versions";
    })
    (config: let
      activationScript = config.home.activation.installAsdfPlugins.data or "";
    in {
      assertion = !(lib.strings.hasInfix "asdf install" activationScript);
      message = "Activation script should not contain 'asdf install' when skipPluginSync is true";
    })
    (config: let
      activationScript = config.home.activation.installAsdfPlugins.data or "";
    in {
      assertion = !(lib.strings.hasInfix "asdf plugin add" activationScript);
      message = "Activation script should not contain 'asdf plugin add' when skipPluginSync is true";
    })
    (config: let
      activationScript = config.home.activation.installAsdfPlugins.data or "";
    in {
      assertion = !(lib.strings.hasInfix "asdf plugin update" activationScript);
      message = "Activation script should not contain 'asdf plugin update' when skipPluginSync is true";
    })
  ];
}
