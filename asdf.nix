{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.asdf;
in
{
  options.asdf = {
    enable = mkEnableOption "ASDF Version Manager";
    direnv = mkEnableOption "Use direnv";

    package = mkOption {
      type = types.package;
      description = "ASDF package to use";
      default = pkgs.asdf-vm;
    };

    nodejs = mkOption {
      description = "Nodejs";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Nodejs plugin";
          npmDefaultPackages = mkOption {
            type = with types; listOf str;
            description = "What npm packages to install by default";
            default = [ ];
          };
        };
      };
      default = { };
    };

    plugins = mkOption {
      type = with types; listOf (enum [
        "direnv"
        "nodejs"
        "skaffold"
        "kubectl"
        "kustomize"
      ]);
      description = "What plugins to install";
      default = [ ];
    };
  };
  config = mkIf cfg.enable (
    mkMerge [{
      home = {
        packages = [
          config.asdf.package
        ];
      };
    }
      (mkIf cfg.nodejs.enable {
        home = {
          file = mkIf ((builtins.length cfg.nodejs.npmDefaultPackages) > 0) {
            ".default-npm-packages".text = builtins.concatStringsSep "\n" cfg.nodejs.npmDefaultPackages;
          };
          sessionVariables = {
            ASDF_NODEJS_NODEBUILD_HOME = "$HOME/.asdf/build/node-build";
          };
        };
        asdf = {
          plugins = [ "nodejs" ];
        };
      })
      (mkIf cfg.direnv {
        asdf.plugins = [ "direnv" ];
        programs = {
          direnv = {
            enable = true;
            stdlib = ''
              use_asdf() {
                source_env "$(asdf direnv envrc "$@")"
              }
            '';
          };
        };
      })]
  );
}
