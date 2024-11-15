{
  description = "Nix Flake Template for Python using Poetry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = {
    self,
    nixpkgs,
    poetry2nix,
  }: let
    systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    pkgsFor = forEachSystem (system: import nixpkgs {inherit system;});
    poetry2nix-lib = forEachSystem(system: poetry2nix.lib.mkPoetry2Nix { pkgs = pkgsFor.${system}; });
  in {
    formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);

    devShells = forEachSystem (system: let
      poetryEnv = (poetry2nix-lib.${system}.mkPoetryEnv {
        projectDir = ./.;
        editablePackageSources = {
          wallcreate = ./wallcreate;
        };
      });
    in {
      default = pkgsFor.${system}.mkShell {
        packages = with pkgsFor.${system}; [
          poetry
          poetryEnv
        ];
      };
    });

    apps = forEachSystem (system: let
      wallcreate = poetry2nix-lib.${system}.mkPoetryApplication {projectDir = ./.;};
    in {
      default = {
        type = "app";
        program = "${wallcreate}/bin/wallcreate";
      };
    });
  };
}
