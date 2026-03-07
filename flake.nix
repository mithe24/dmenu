{
    description = "dmenu";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = nixpkgs.legacyPackages.${system};
            in
                {
                packages.default = pkgs.stdenv.mkDerivation {
                    pname = "dmenu";
                    version = "4.9";

                    src = ./.;

                    buildInputs = with pkgs; [
                        xorg.libX11
                        xorg.libXft
                        xorg.libXinerama
                        freetype
                        fontconfig
                    ];

                    nativeBuildInputs = with pkgs; [
                        pkg-config
                    ];

                    makeFlags = [ "PREFIX=$(out)" ];
                };

                devShells.default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                        xorg.libX11
                        xorg.libXft
                        xorg.libXinerama
                        freetype
                        fontconfig
                        pkg-config

                        # Dev tools
                        clang
                        gcc
                        gnumake
                        gdb
                    ];
                };
            }
        );
}
