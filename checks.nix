{ lib, self, darwin, system, home-manager }:
let
  hasPackage = package: c: lib.lists.any (x: x ? pname && x.pname == package) c.home-manager.users.test.home.packages;
in
{
  disabled = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
        };
        assertions = [
          {
            assertion = !config.home-manager.users.test.programs.direnv.enable;
            message = " Direnv should be disabled";
          }
          {
            assertion = !(lib.strings.hasInfix "asdf" config.home-manager.users.test.programs.direnv.stdlib);
            message = "ASDF for Direnv should be disabled";
          }
          {
            assertion = !(hasPackage "asdf-vm" config);
            message = "ASDF should not be included as a package";
          }
        ];
      })
    ];
  }).system;
  withoutDirenv = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
          };
        };
        assertions = [
          {
            assertion = !(lib.strings.hasInfix "asdf" config.home-manager.users.test.programs.direnv.stdlib);
            message = "ASDF for Direnv should be disabled";
          }
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
        ];
      })
    ];
  }).system;
  withDirenv = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            direnv = true;
          };
        };
        assertions = [
          {
            assertion = config.home-manager.users.test.programs.direnv.enable;
            message = " Direnv should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "asdf" config.home-manager.users.test.programs.direnv.stdlib;
            message = "Direnv not configured for Asdf";
          }
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
        ];
      })
    ];
  }).system;
  withNodejs = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            direnv = true;
            nodejs = {
              enable = true;
              npmDefaultPackages = [ "yarn" ];
            };
          };
        };
        assertions = [
          {
            assertion = config.home-manager.users.test.programs.direnv.enable;
            message = " Direnv should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "asdf" config.home-manager.users.test.programs.direnv.stdlib;
            message = "Direnv not configured for Asdf";
          }
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
        ];
      })
    ];
  }).system;
  
  withGolang = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            golang = {
              enable = true;
              defaultVersion = "1.24.3";
            };
          };
        };
        assertions = [
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
          {
            assertion = lib.elem "golang" config.home-manager.users.test.programs.asdf.plugins;
            message = "Golang plugin should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "golang 1.24.3" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Golang version should be set in .tool-versions";
          }
        ];
      })
    ];
  }).system;
  
  withTerraform = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            terraform = {
              enable = true;
              defaultVersion = "1.5.5";
            };
          };
        };
        assertions = [
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
          {
            assertion = lib.elem "terraform" config.home-manager.users.test.programs.asdf.plugins;
            message = "Terraform plugin should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "terraform 1.5.5" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Terraform version should be set in .tool-versions";
          }
        ];
      })
    ];
  }).system;
  
  withOpenTofu = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            opentofu = {
              enable = true;
              defaultVersion = "1.9.0";
            };
          };
        };
        assertions = [
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
          {
            assertion = lib.elem "opentofu" config.home-manager.users.test.programs.asdf.plugins;
            message = "OpenTofu plugin should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "terraform 1.9.0" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "OpenTofu version should be set in .tool-versions as terraform";
          }
        ];
      })
    ];
  }).system;
  
  withRuby = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            ruby = {
              enable = true;
              defaultVersion = "3.4.2";
              defaultPackages = [ "bundler" "pry" ];
            };
          };
        };
        assertions = [
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
          {
            assertion = lib.elem "ruby" config.home-manager.users.test.programs.asdf.plugins;
            message = "Ruby plugin should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "ruby 3.4.2" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Ruby version should be set in .tool-versions";
          }
          {
            assertion = lib.strings.hasInfix "bundler" (builtins.readFile config.home-manager.users.test.home.file.".default-ruby-packages".source);
            message = "Ruby default packages should be set";
          }
        ];
      })
    ];
  }).system;
  
  withPython = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            python = {
              enable = true;
              defaultVersion = "3.13.2";
              defaultPackages = [ "pip" "pytest" ];
            };
          };
        };
        assertions = [
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
          {
            assertion = lib.elem "python" config.home-manager.users.test.programs.asdf.plugins;
            message = "Python plugin should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "python 3.13.2" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Python version should be set in .tool-versions";
          }
          {
            assertion = lib.strings.hasInfix "pip" (builtins.readFile config.home-manager.users.test.home.file.".default-python-packages".source);
            message = "Python default packages should be set";
          }
        ];
      })
    ];
  }).system;
  
  withMultiplePlugins = (darwin.lib.darwinSystem {
    inherit system;

    modules = [
      home-manager.darwinModules.home-manager
      self.nixosModule
      ({ config, pkgs, lib, ... }: {
        home-manager.useGlobalPkgs = true;
        users.users.test = { };
        home-manager.users.test = {
          home.stateVersion = "21.11";
          asdf = {
            enable = true;
            direnv = true;
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
        };
        assertions = [
          {
            assertion = hasPackage "asdf-vm" config;
            message = "ASDF should be included as a package";
          }
          {
            assertion = lib.elem "nodejs" config.home-manager.users.test.programs.asdf.plugins;
            message = "NodeJS plugin should be enabled";
          }
          {
            assertion = lib.elem "golang" config.home-manager.users.test.programs.asdf.plugins;
            message = "Golang plugin should be enabled";
          }
          {
            assertion = lib.elem "ruby" config.home-manager.users.test.programs.asdf.plugins;
            message = "Ruby plugin should be enabled";
          }
          {
            assertion = lib.elem "python" config.home-manager.users.test.programs.asdf.plugins;
            message = "Python plugin should be enabled";
          }
          {
            assertion = lib.elem "terraform" config.home-manager.users.test.programs.asdf.plugins;
            message = "Terraform plugin should be enabled";
          }
          {
            assertion = lib.strings.hasInfix "nodejs 22.14.0" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "NodeJS version should be set in .tool-versions";
          }
          {
            assertion = lib.strings.hasInfix "golang 1.24.3" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Golang version should be set in .tool-versions";
          }
          {
            assertion = lib.strings.hasInfix "ruby 3.4.2" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Ruby version should be set in .tool-versions";
          }
          {
            assertion = lib.strings.hasInfix "python 3.13.2" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Python version should be set in .tool-versions";
          }
          {
            assertion = lib.strings.hasInfix "terraform 1.5.5" (builtins.readFile config.home-manager.users.test.home.file.".tool-versions".source);
            message = "Terraform version should be set in .tool-versions";
          }
        ];
      })
    ];
  }).system;
}
