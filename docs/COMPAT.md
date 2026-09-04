# COMPAT.md

Human ledger of every stub and NixOS-ism. Machine source of truth is [schema/scripts.lock.json](../schema/scripts.lock.json) and [schema/packages.map.json](../schema/packages.map.json). If prose and JSON disagree, JSON wins and this file must be updated in the same commit.

Status at skeleton time: **classes are decided, inventory is not yet generated from v4.0.2 `bin/`**. Merci fills the inventory during the first pin. Do not pretend the tables below are complete.

## How to read a row

| Field | Meaning |
|---|---|
| id | stable slug |
| class | `vendor` `wrap` `stub` `host` `na` `drop` |
| upstream | path or command in omarchy-src |
| stand-in | NixOS option, wrap script, or none |
| user-visible | yes if a menu, keybind, or first-run can reach it |
| since | first Omahedron tag that recorded it |

Classes are defined in [SCHEMA.md](SCHEMA.md).

## Must stay N/A or host-owned

These are the brief’s permanent gaps. They stay listed even after the inventory exists.

| id | class | upstream | stand-in | notes |
|---|---|---|---|---|
| pacman | na | pacman, yay, AUR, pkgs.omarchy.org | flake packages + rebuild | never install host pacman |
| channel-switcher-arch | na | official channel TUI as Arch implements it | change flake input | stub if a menu reaches it |
| official-kernel-pkg | na | linux-ptl / Omarchy Kernel `.pkg.tar.zst` | `boot.kernelPackages` | later optional derivation |
| limine-snapper-uki | na | Limine, Snapper, mkinitcpio UKI | systemd-boot + generations | |
| iso-apply | na | ISO, `omarchy-apply-system`, `omarchy-apply-hardware` | NixOS hardware modules | |
| mutable-usr | na | `/usr/share/omarchy`, `omarchy-dev-link` | store `$OMARCHY_PATH` | |
| omacom-support | na | Foundation patronage features that assume Arch | none | do not claim |
| plugins-arch-root | na | marketplace entries that pacman-install or write `/etc` as root | stub UI if present | ADR-0010 |
| mise-opt | na | mise tarball under `/opt` | nixpkgs / flakes / devshells | |
| day-one-vendor-kernel | na | same-week Dell/Intel kernels as Arch packages only | wait for nixpkgs | |

## Desktop targets that must match the pinned tag

When metal-green, these are not optional:

- One Quickshell process and its plugins
- Hyprland Lua bootstrap + `~/.config` overrides
- Theme engine (TOML + templates), live swap
- Default bindings
- First-run provisioning with Nix-seeded identity
- `omarchy-*` that are reached and classified `vendor` or `wrap`
- Fish interactive default (opt-out allowed)
- Agent surface: Cursor, Grok (v1); others first-class

## Known NixOS-isms (inherit and verify on first pin)

Recorded from zicochaos UPSTREAM.md. Re-verify against v4.0.2; do not copy blindly if the file moved.

| Area | Upstream | Omahedron | Why |
|---|---|---|---|
| Tree location | `/usr/share/omarchy` | `$out/share/omarchy` | store |
| Bin on PATH | `/usr/bin/omarchy-*` | `$OMARCHY_PATH/bin` prepended | session PATH |
| OMARCHY_PATH source | profile.d / dev-link | sessionVariables + uwsm env | no Arch dev-link |
| Theme render trigger | ISO chroot | HM activation | no ISO stage |
| First-run | `install/user/first-run/*.sh` | vendored provision on first login | invitation hooks pre-marked; Arch steps no-op |
| Hyprland package | Arch hyprland | flake input ≥0.56 | 26.05 nixpkgs lagged 0.55.4 at zico writing |
| Browser desktop id | `chromium.desktop` | alias `chromium-browser.desktop` | NixOS naming |
| Update | pacman + omarchy update | flake update + rebuild | wrap |

## Phased items (destination yes, not v1 gate)

| id | v1 class expected | later |
|---|---|---|
| webapps | stub or partial wrap | v1.1 wrap |
| voxtype | stub unless cheap | v1.2 |
| fingerprint | host / stub | v1.2 if hardware present |
| windows-vm | stub | v1.2 wrap-or-stub from call sites |

## Honesty rules (Vini)

- A stub that says `na: pacman` is correct. A wrap that half-calls pacman is not.
- Do not mark metal-green from a VM.
- Do not delete a gap from this file because it is embarrassing. Move it to a new class with an ADR.
