{ pkgs ? import <nixpkgs> }:
pkgs.mkShell {
 packages = with pkgs; [
    libyaml
    openssl
  ];
  buildInputs = [

  ];
}
