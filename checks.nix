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
          #{
          #  assertion = lib.strings.hasInfix "node-build" config.home-manager.users.test.home.sessionVariables.ASDF_NODEJS_NODEBUILD_HOME;
          #  message = "Node build not configured";
          #}
        ];
      })
    ];
  }).system;
}
