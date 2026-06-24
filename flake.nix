{
  description = "Personal Nix package collection";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ];
    in {
      packages = forAllSystems (system:
        let
          # keka.meta.license is `unfree` — flake outputs are evaluated with their
          # own pkgs instance, so the consumer's `nixpkgs.config.allowUnfree` never
          # propagates here. Allowlist by name instead of blanket-allowing unfree.
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "keka" ];
          };
          inherit (nixpkgs) lib;
        in {
          keka = pkgs.callPackage ./pkgs/keka/package.nix { };
        });
    };
}
