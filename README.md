# 📦 nix-packages

A small personal collection of Nix flake packages — for software that's either:

- 🐌 **stale in nixpkgs** — the upstream maintainer hasn't bumped the version in a while, and version-bump PRs can sit unreviewed for weeks or months
- 🚫 **missing from nixpkgs entirely**

Rather than pile up local overlay overrides or wait on someone else's schedule, these packages live here as proper, buildable flake outputs — easy to pull into any flake-based config.

## 📋 Packages

| Package | Version here | Version in nixpkgs | Why |
|---|---|---|---|
| [`keka`](./pkgs/keka) | `1.6.7` | [`1.6.0`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ke/keka/package.nix) | several patch releases behind, no auto-update mechanism upstream |
| [`supacode`](./pkgs/supacode) | `0.10.4` | not in nixpkgs | frequent releases during beta phase, not suited for nixpkgs review cycle |

## 🚀 Usage

Add this flake as an input:

```nix
inputs.nix-packages.url = "github:imTHAI/nix-packages";
inputs.nix-packages.inputs.nixpkgs.follows = "nixpkgs"; # avoid pulling a second nixpkgs closure
```

Then reference any package as a flake output:

```nix
environment.systemPackages = [
  inputs.nix-packages.packages.${pkgs.stdenv.hostPlatform.system}.keka
];
```

## 🔄 Staying fresh

Each `package.nix` mirrors the `pkgs/by-name/` convention used by nixpkgs itself, so a package here is nearly a drop-in diff if it's ever worth upstreaming.

A [scheduled GitHub Action](./.github/workflows/update.yml) runs [`nix-update`](https://github.com/Mic92/nix-update) every Monday, rebuilds to confirm the new version works, and opens a PR whenever a newer upstream release shows up — so version bumps stay a reviewable diff, not a silent push. 🤖
