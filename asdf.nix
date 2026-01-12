{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.asdf;
in {
  options.programs.asdf = {
    enable = mkEnableOption "ASDF Version Manager";

    package = mkOption {
      type = types.package;
      description = "ASDF package to use";
      default = pkgs.asdf-vm;
    };

    # Automatically set plugins based on enabled configuration
    plugins = mkOption {
      type = with types; listOf str;
      description = "Plugins to install";
      default = [];
      example = [
        "nodejs"
        "python"
      ];
    };

    direnv = mkOption {
      description = "Direnv";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable direnv integration";
        };
      };
      default = {};
    };

    nodejs = mkOption {
      description = "Nodejs";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Nodejs plugin";
          defaultPackages = mkOption {
            type = with types; listOf str;
            description = "Packages to install by default";
            default = [];
          };

          defaultVersion = mkOption {
            type = types.str;
            description = "Default System version to install";
            default = "22.14.0";
          };
        };
      };
      default = {};
    };

    ruby = mkOption {
      description = "Ruby";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Ruby plugin";
          defaultPackages = mkOption {
            type = with types; listOf str;
            description = "Packages to install by default";
            default = [];
          };

          defaultVersion = mkOption {
            type = types.str;
            description = "Default System version to install";
            default = "3.4.2";
          };
        };
      };
      default = {};
    };

    python = mkOption {
      description = "Python";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Python plugin";
          defaultPackages = mkOption {
            type = with types; listOf str;
            description = "Packages to install by default";
            default = [];
          };

          defaultVersion = mkOption {
            type = types.str;
            description = "Default System version to install";
            default = "3.13.2";
          };
        };
      };
      default = {};
    };

    terraform = mkOption {
      description = "Terraform";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Terraform plugin";
          defaultVersion = mkOption {
            type = types.str;
            description = "Default System version to install";
            default = "1.5.5";
          };
        };
      };
      default = {};
    };

    opentofu = mkOption {
      description = "OpenTofu";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable OpenTofu plugin";
          defaultVersion = mkOption {
            type = types.str;
            description = "Default System version to install";
            default = "1.9.0";
          };
        };
      };
      default = {};
    };

    golang = mkOption {
      description = "Golang";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Golang plugin";
          defaultVersion = mkOption {
            type = types.str;
            description = "Default System version to install";
            default = "1.24.3";
          };
        };
      };
      default = {};
    };

    skaffold = mkOption {
      description = "Skaffold";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Skaffold plugin";
        };
      };
      default = {};
    };

    kubectl = mkOption {
      description = "Kubectl";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Kubectl plugin";
        };
      };
      default = {};
    };

    kustomize = mkOption {
      description = "Kustomize";
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Kustomize plugin";
        };
      };
      default = {};
    };

    config = mkOption {
      type = types.attrsOf types.str;
      description = "Settings that would be placed in the .asdfrc file";
      default = {};
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.asdf.plugins = let
        isPluginEnabled = name:
          builtins.hasAttr name cfg
          && builtins.isAttrs cfg.${name}
          && builtins.hasAttr "enable" cfg.${name}
          && cfg.${name}.enable;

        supportedPlugins = [
          "nodejs"
          "python"
          "ruby"
          "skaffold"
          "kubectl"
          "kustomize"
          "terraform"
          "opentofu"
          "golang"
        ];
        enabledPlugins = builtins.filter isPluginEnabled supportedPlugins;
      in
        enabledPlugins;

      home = {
        packages = [
          cfg.package

          pkgs.git
          pkgs.gawk
          pkgs.gnutar
          pkgs.gzip
          pkgs.libyaml
          pkgs.libyaml.dev
          pkgs.openssl
          pkgs.openssl.dev
        ];

        file = mkMerge [
          (
            let
              toolVersions =
                []
                ++ (optional (cfg.nodejs.enable && cfg.nodejs.defaultVersion != "") "nodejs ${cfg.nodejs.defaultVersion}")
                ++ (optional (cfg.ruby.enable && cfg.ruby.defaultVersion != "") "ruby ${cfg.ruby.defaultVersion}")
                ++ (optional (cfg.python.enable && cfg.python.defaultVersion != "") "python ${cfg.python.defaultVersion}")
                ++ (optional (cfg.terraform.enable && cfg.terraform.defaultVersion != "") "terraform ${cfg.terraform.defaultVersion}")
                ++ (optional (cfg.opentofu.enable && cfg.opentofu.defaultVersion != "") "opentofu ${cfg.opentofu.defaultVersion}")
                ++ (optional (cfg.golang.enable && cfg.golang.defaultVersion != "") "golang ${cfg.golang.defaultVersion}");
            in
              mkIf (toolVersions != []) {
                ".tool-versions" = {
                  text = concatStringsSep "\n" toolVersions + "\n";
                };
              }
          )

          (mkIf (cfg.config != {}) {
            ".asdfrc" = {
              text = builtins.concatStringsSep "\n" (mapAttrsToList (k: v: "${k} = ${v}") cfg.config);
            };
          })
        ];

        # Add activation script to install plugins
        activation.installAsdfPlugins = lib.hm.dag.entryAfter ["writeBoundary" "linkGeneration"] (
          let
            # Filter out non-package items and create path stringf
            packageBinPaths = concatStringsSep ":" (
              map (pkg: "${pkg}/bin") (
                builtins.filter (p: p ? type && p.type == "derivation") config.home.packages
              )
            );

            packageLibnPaths = concatStringsSep ":" (
              map (pkg: "${pkg}/lib") (
                builtins.filter (p: p ? type && p.type == "derivation") config.home.packages
              )
            );
          in ''
            # Ensure PATH includes home-manager paths
            export PATH="${config.home.profileDirectory}/bin:${packageBinPaths}:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:$PATH"

            export MAKE_OPTS=-j$(nproc)
            export RUBY_CONFIGURE_OPTS="--with-libyaml-dir=${pkgs.libyaml.dev}" # This is required for ruby to discover libyaml


            if [ -x "${cfg.package}/bin/asdf" ]; then
              echo "Managing ASDF plugins..."

              # Get currently installed plugins
              installed_plugins=$(${cfg.package}/bin/asdf plugin list 2>/dev/null || echo "")

              # Install configured plugins
              ${concatMapStringsSep "\n" (plugin: ''
                if ! echo "$installed_plugins" | grep -q "^${plugin}$"; then
                  echo "Installing plugin: ${plugin}"
                  ${if plugin == "golang" then ''
                    ${cfg.package}/bin/asdf plugin add "${plugin}" https://github.com/asdf-community/asdf-golang.git
                  '' else ''
                    ${cfg.package}/bin/asdf plugin add "${plugin}"
                  ''}
                fi
              '')
              cfg.plugins}

              # Update all plugins to latest versions
              echo "Updating plugins..."
              ${cfg.package}/bin/asdf plugin update --all

              # Install configured tool versions
              if [ -f "$HOME/.tool-versions" ]; then
                echo "Installing configured tool versions..."
                ${cfg.package}/bin/asdf install
              fi

              # Remove plugins that are not configured
              if [ -n "$installed_plugins" ]; then
                echo "$installed_plugins" | while read -r plugin; do
                  if [[ -n "$plugin" ]] && ! echo "${concatStringsSep " " cfg.plugins}" | grep -q "$plugin"; then
                    echo "Removing unused plugin: $plugin"
                    ${cfg.package}/bin/asdf plugin remove "$plugin"
                  fi
                done
              fi
            fi
          ''
        );
      };
    }

    (mkIf cfg.nodejs.enable {
      home = {
        file = mkMerge [
          (mkIf ((builtins.length cfg.nodejs.defaultPackages) > 0) {
            ".default-npm-packages".text = builtins.concatStringsSep "\n" cfg.nodejs.defaultPackages;
          })
        ];

        sessionVariables = {
          ASDF_NODEJS_NODEBUILD_HOME = "$HOME/.asdf/build/node-build";
        };
      };
    })

    (mkIf cfg.python.enable {
      home = {
        file = mkIf ((builtins.length cfg.python.defaultPackages) > 0) {
          ".default-python-packages".text = builtins.concatStringsSep "\n" cfg.python.defaultPackages;
        };
      };
    })

    (mkIf cfg.ruby.enable {
      home = {
        file = mkIf ((builtins.length cfg.ruby.defaultPackages) > 0) {
          ".default-ruby-packages".text = builtins.concatStringsSep "\n" cfg.ruby.defaultPackages;
        };
      };
    })

    (mkIf cfg.direnv.enable {
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
    })
  ]);
}
