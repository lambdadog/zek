{
  description = "My personal fork of ZEK, the Zig Editor of Knowledge";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, zig, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.zek = pkgs.stdenv.mkDerivation {
          pname = "zek";
          version = "0.1";

          src = ./.;

          nativeBuildInputs = [ zig.packages.${system}."0.10.0" ];

          # https://github.com/ziglang/zig/issues/6810
          preBuild = ''
            export HOME=$TMPDIR
          '';

          installPhase = ''
            zig build --prefix $out install
          '';
        };

        defaultPackage = packages.zek;
        apps.zek = flake-utils.lib.mkApp { drv = packages.zek; };
        defaultApp = apps.zek;
      });
}
