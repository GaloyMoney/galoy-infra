{
  description = "Dev shell for galoy-infra";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in
      with pkgs; {
        devShells.default = mkShell
          {
            nativeBuildInputs = [
              alejandra
              opentofu
              ytt
              azure-cli
              jq
            ];
          };

        formatter = alejandra;
      });
}
