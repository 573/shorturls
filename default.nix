{ compiler ? "ghc865" }:

let
  bootstrap = import <nixpkgs> {};
  nixpkgs = builtins.fromJSON (builtins.readFile ./nixpkgs-19.09.json);
  src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs";
    inherit (nixpkgs) rev sha256;
  };
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = hspkgsNew: hspkgsOld: rec {
#              shorturls = hspkgsNew.callPackage ./shorturls.nix {};
              shorturls =
                pkgs.haskell.lib.overrideCabal
                  (pkgs.haskell.lib.doCheck (hspkgsNew.callPackage ./shorturls.nix {}))
                  (oldDerivation: {
                    buildDepends = [ pkgs.redis ];
                    preCheck = ''
                      echo =======Prepare env for integration tests=======
                      redis-server --daemonize yes
                      redis-cli ping
                    '';
                    postCheck = ''
                      echo =======Shutdown redis==========================
                      redis-cli shutdown
                    '';
                 });
              shorturls-static =
                pkgs.haskell.lib.overrideCabal
                  (pkgs.haskell.lib.justStaticExecutables (hspkgsNew.callPackage ./shorturls.nix {}))
                  (oldDerivation: {
                    configureFlags = [
                      "--ghc-option=-optl=-static"
                      "--ghc-option=-optl=-pthread"
                      "--ghc-option=-optl=-L${pkgs.gmp5.static}/lib"
                      "--ghc-option=-optl=-L${pkgs.zlib.static}/lib"
                      "--ghc-option=-optl=-L${pkgs.glibc.static}/lib"
                    ];
                  });
            };
          };
        };
      };
    };
  };
  pkgs = import src { inherit config; };

#  pkgs = import (builtins.fetchGit {
#  # Descriptive name to make the store path easier to identify
#  name = "nixos-17.09-2019-12-17";
#  name = "nixos-19.09-2020-01-08";
#  url = https://github.com/nixos/nixpkgs-channels;
#  # Commit hash for nixos-17.09 as of 2019-12-17
#  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-17.09`
#  rev = "14f9ee66e63077539252f8b4550049381a082518";
#  rev = "fd4ccdbe3a68478a7f442cd4ee2dfff9644ef7ee";
#  ref = "nixos-17.09";
#  ref = "nixos-19.09";

in
{ shorturls = pkgs.haskell.packages.${compiler}.shorturls;
# error with ghc865/nix-19.09 when building static, see glibc-error-log.gist
#  shorturls-static = pkgs.haskell.packages.${compiler}.shorturls-static;
#  name = "";
#  test = pkgs.nixosTest ./test.nix;
}
