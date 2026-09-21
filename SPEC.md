# SPEC.md

Product specification for Omahedron. Version of this document: **0.4**, revised by ADR-0027 (2026-09-21).

Change this file only with an ADR.

## One sentence

Omahedron is a theme and plugin pack for stock Omarchy: Hedron and Hedron Light ship as theme directories, and a thin Nix flake can install them for Arch Omarchy and Omarchy-Nix users.

## Source of truth

| Domain | Winner | Artifact |
|---|---|---|
| What the theme looks like | The theme directory | `themes/hedron`, `themes/hedron-light` |
| How a stranger installs it | This spec and the README | [README.md](README.md), [docs/install.md](docs/install.md) |
| Optional Nix install | The root flake | `flake.nix`, `nix/` |
| Retired desktop port | The archive | [legacy/os-port/](legacy/os-port/) |
| Decisions | An ADR | [DECISIONS.md](DECISIONS.md) |

Omarchy's own theme engine renders `colors.toml`. Omahedron does not reimplement Quickshell, theme templates, or the script router.

## Success metric

Someone who already runs stock Omarchy can follow the README, land both themes in `~/.config/omarchy/themes/`, and run `omarchy theme set hedron` or `omarchy theme set hedron-light`. The wallpaper, palette, and lock-screen copper or bronze border come from this repository.

A Nix user can do the same with `homeManagerModules.default` and `omahedron.themes.enable`, without `allowUnfree` and without a desktop module.

## In scope

- `themes/hedron` and `themes/hedron-light`, including wallpapers
- Theme files a stock Omarchy theme directory carries at v4.0.3, with Hedron-colored stubs for the files the packs omitted (`keyboard.rgb`, `neovim.lua`, `shell.lock.toml`, `vscode.json`)
- README install: copy or symlink, then `omarchy theme set`
- Optional flake overlay, theme package, and opt-in Home Manager and NixOS modules that only install themes
- Honest plugin targets: Facet, Geode, Lapis, Hedronos / fullstack-lab, shipped only when each has an artifact in this repo

## Out of scope

- A NixOS port of the Omarchy desktop as the product (archived under `legacy/os-port/`, last tag `omahedron-4.0.3`)
- Tracking Omarchy `master` / `quattro` as a user-facing desktop pin
- Host pacman, an Omarchy ISO, or a second bootloader
- `allowUnfree` or Steam-style unfree as a default
- Affiliation with Basecamp, 37signals, or Omacom
- The reserved brand Omarchanite
- Inventing a Hedron-native Neovim or VS Code marketplace extension. Editor stubs name published schemes.

## Release identity

User-facing versions of the archived desktop port were Omarchy `vX.Y.Z` and flake tags `omahedron-X.Y.Z`. Those tags remain the port. This repository's current product is the theme pack on `main`. Do not mint a parallel 0.x desktop version.

## Consumers

1. Stock Omarchy on Arch, installing themes by symlink or copy.
2. Omarchy-Nix (or any Nix host that runs stock Omarchy), installing the same directories through the flake.
