# Omahedron

Hedronite's independently maintained **trailing-stable rebuild of the Omarchy desktop** on NixOS.

Omahedron is to [Omarchy](https://omarchy.org) what Rocky Linux / AlmaLinux are to CentOS: same product surface at a blessed upstream version, different governance, no vendor support contract.

That analogy has a hard edge. Rocky rebuilds the same OS family. Omahedron rebuilds the **desktop layer** (Hyprland + one Quickshell process + themes + `omarchy-*` that are not package-manager or boot) on NixOS. It does not rebuild the Omarchy installer, pacman repo, Limine/Snapper/UKI pipeline, or official kernel packages.

This repository is the working tree for the Hedronite agent fleet. It is intended to become a public flake others can consume. It is **not** official Omarchy and does not claim Omacom support.

| | |
|---|---|
| Product | Omahedron |
| Org | Hedronite |
| Category descriptor | nix-omarchy (do not use as the product name) |
| Reserved sibling brand | Omarchanite (other substrate, TBD — not this repo) |
| Upstream desktop | [basecamp/omarchy](https://github.com/basecamp/omarchy) tag **v4.0.2** |
| Glue provenance | Fork-and-improve [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix) |
| Default nixpkgs pair | NixOS 26.05 until a planned 26.11 cutover |
| License | MIT, with full credit — see [docs/CREDITS.md](docs/CREDITS.md) |

## Current pin (v0 working tree)

| Field | Value |
|---|---|
| Claimed desktop | Omarchy v4.0.2 (released 2026-08-31) |
| Flake tag when first shipped | `omahedron-4.0.2` |
| Channel | `stable` (default) |
| Frozen | pin/v4.0.2 — omarchy-src locked to tag v4.0.2 (`346e69e1…`); metal not yet |
| Metal gate | Dell Latitude 5420, 8 GB, Intel iGPU |
| Dogfood doctrine | lite / bare-minimum: all tools installed, not all loaded |

## What you get when this is real

A NixOS machine that looks and drives like official Omarchy stable:

- One Quickshell process (bar, launcher, menus, notifications, OSDs, lock, polkit)
- Hyprland Lua bootstrap + user overrides in `~/.config`
- TOML + template theme engine with live swap
- `omarchy-*` commands that are not package-manager or boot specific
- Default bindings and first-run provisioning (Nix-seeded identity)
- Fish as the default interactive shell (bash remains the script runtime)
- First-class agent surface: Cursor and Grok first; Cline, OpenCode, Devin, OMP first-class

Documented OS-layer gaps live in [`docs/COMPAT.md`](docs/COMPAT.md) and the machine-readable ledger in [`schema/scripts.lock.json`](schema/scripts.lock.json).

## What you do not get

pacman, yay, AUR, pkgs.omarchy.org, official Omarchy Kernel / linux-ptl as Arch packages, Limine, Snapper, mkinitcpio UKI, the official ISO, `omarchy-apply-system` / `omarchy-apply-hardware`, mutable `/usr/share/omarchy`, Omacom support, same-week hardware enablement that ships only as Arch packages.

## Architecture (do not reopen)

```
flake.nix                 # inputs: nixpkgs, home-manager, hyprland, omarchy-src
pkgs/omarchy.nix          # vendor tree → $out/share/omarchy
pkgs/<name>.nix           # only packages not in nixpkgs
modules/nixos/            # session, greeter, audio, portals, firmware, kernel
modules/home-manager/     # theme render, first-run, user files
docs/COMPAT.md            # every stub and NixOS-ism
docs/UPSTREAM.md          # bump checklist
checks/                   # eval + behavioral UX
schema/                   # script ledger, package map, bump records
```

Vendor rule: if the user can see it, it comes from `omarchy-src`. If NixOS already models it, declare the NixOS option. “It would be cleaner in Nix” is not a reason to rewrite Quickshell, the theme engine, or the script tree.

- `$OMARCHY_PATH` = store path `$out/share/omarchy`
- Session PATH prepends `$OMARCHY_PATH/bin`
- Patches use `substituteInPlace --replace-fail`
- One upstream rev + glue fixes = one commit
- Do not copy scripts into a writable `/usr`

## Start here

| If you are | Read |
|---|---|
| Any agent landing in this repo | [AGENTS.md](AGENTS.md) then [SPEC.md](SPEC.md) |
| Eli (orchestrator) | [AGENTS.md](AGENTS.md), [ROADMAP.md](ROADMAP.md), [DECISIONS.md](DECISIONS.md) |
| Lea / Marci (glue, vendor, packages) | [docs/UPSTREAM.md](docs/UPSTREAM.md), [docs/SCHEMA.md](docs/SCHEMA.md) |
| Vini (security / honesty) | [docs/COMPAT.md](docs/COMPAT.md), [docs/CHANNELS.md](docs/CHANNELS.md) |
| Sati (what the user sees) | [docs/METAL.md](docs/METAL.md), [checklists/metal.md](checklists/metal.md) |
| Merci (inventories) | [schema/](schema/), [templates/bump-record.md](templates/bump-record.md) |
| Leo (human words) | this README, [docs/CREDITS.md](docs/CREDITS.md), [templates/changelog.md](templates/changelog.md) |
| Human daily-driving the Latitude | [checklists/metal.md](checklists/metal.md), [docs/CHANNELS.md](docs/CHANNELS.md) |

## Status of this drop

`pin/v4.0.2` adopts the [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix) port (`flake.nix`, `pkgs/`, `modules/`, `tests/`, `example/`, `skills/`) and locks `omarchy-src` to Omarchy tag **v4.0.2** (`346e69e1…`). Constitution docs, LICENSE, and CREDITS stay. Latitude metal and tag `omahedron-4.0.2` are **out of scope** for this pin PR.

## Channels (names only)

| Channel | `omarchy-src` | nixpkgs | Who |
|---|---|---|---|
| `stable` (default) | Official tag `vX.Y.Z` | nixos-stable (26.05 now) | Users + Latitude daily |
| `rc` | Official RC tag when one exists | same as stable unless blocked | Maintainer VM generation |
| `edge` | `quattro` or master | nixos-unstable | Maintainer only, never called 1:1 |

Policy detail: [docs/CHANNELS.md](docs/CHANNELS.md).

## License and credit

MIT. Desktop sources from Basecamp/Omacom Omarchy. Nix glue derived from zicochaos/omarchy-nix. Full attribution in [docs/CREDITS.md](docs/CREDITS.md).
