{
  description = "ASDF for nix";

  inputs = {
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
      home-manager,
      flake-utils,
      ...
    }:
    {
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
