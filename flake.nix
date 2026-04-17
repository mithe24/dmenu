{
  description = "dmenu";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              dmenu = prev.dmenu.overrideAttrs (_oldAttrs: {
                version = "5.3";
                src = ./.;
              });
            })
          ];
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            clang-format = {
              enable = true;
              includes = ["*.c" "*.h"];
            };
          };
        };
      in {
        packages = {
          dmenu = pkgs.dmenu;
          default = pkgs.dmenu;
        };
        apps = {
          dmenu = {
            type = "app";
            program = "${pkgs.dmenu}/bin/dmenu";
          };
          dmenu_run = {
            type = "app";
            program = "${pkgs.dmenu}/bin/dmenu_run";
          };
          default = {
            type = "app";
            program = "${pkgs.dmenu}/bin/dmenu";
          };
        };
        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            libx11
            libxft
            libxinerama
            gcc
            clang-tools
            bear
          ];
        };
      }
    );
}
