{
  description = "ASDF for nix";

  inputs = {
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # ASDF Plugins
    plugin-direnv = {
      url = "github:asdf-community/asdf-direnv/v0.3.0";
      flake = false;
    };

    plugin-nodejs = {
      url = "github:asdf-vm/asdf-nodejs";
      flake = false;
    };
  };
  outputs = inputs@{ self, darwin, home-manager, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [
      flake-utils.lib.system.x86_64-darwin
      flake-utils.lib.system.aarch64-darwin
    ]
      (system:
        let
          p = import nixpkgs {
            inherit system;
          };
        in
        {

          checks = (import ./checks.nix) {
            lib = nixpkgs.lib;
            inherit
              darwin
              system
              home-manager
              self;
          };
          devShell = (import ./shell.nix) {
            pkgs = p;
          };
        }
      ) // {
      nixosModule = {
        home-manager.sharedModules = [
          ./asdf.nix
          ({ config, lib, pkgs, ... }:
            {
              home.file = builtins.listToAttrs
                (builtins.map
                  (x: {
                    name = ".asdf/plugins/${x}";
                    value = {
                      source = inputs."plugin-${x}";
                    };
                  })
                  config.asdf.plugins);
            })
        ];
      };
    };
}
