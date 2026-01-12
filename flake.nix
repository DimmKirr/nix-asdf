{
  description = "ASDF for nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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

    plugin-skaffold = {
      url = "github:nklmilojevic/asdf-skaffold";
      flake = false;
    };

    plugin-kubectl = {
      url = "github:asdf-community/asdf-kubectl";
      flake = false;
    };

    plugin-kustomize = {
      url = "github:Banno/asdf-kustomize";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      home-manager,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      nixosModule = self.homeManagerModules.default;
      
      checks = import ./checks.nix {
        inherit self darwin system home-manager nixpkgs;
        lib = nixpkgs.lib;
      };
    }) // {
      homeManagerModules.default = import ./asdf.nix;

      darwinModules.default =
        {
          pkgs,
          ...
        }:
        {

        };
    };
}
