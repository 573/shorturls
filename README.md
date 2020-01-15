# shorturls

To generate the nixpkgs-19.09.json file use:

    nix run nixpkgs.nix-prefetch-git -c nix-prefetch-git --no-deepClone --quiet https://github.com/NixOS/nixpkgs.git $(git ls-remote https://github.com/nixos/nixpkgs-channels nixos-19.09 | cut -f 1)
