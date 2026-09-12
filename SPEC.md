# SPEC.md

Product specification for Omahedron. Version of this document: **0.3**, revised by ADR-0025 (2026-09-11). Competitive bar: [docs/COMPETE.md](docs/COMPETE.md).

Change this file only with an ADR. If this file and COMPETE disagree on module defaults (kitchen sink vs thin desktop), COMPETE wins until a newer ADR revises both.

## One sentence

Omahedron ships a Nix flake that makes a NixOS machine look and drive like official Omarchy **stable** (trailing their release tags), with every OS-layer gap written down, a thin desktop profile, and Nix verbs that do not feel like a broken pacman.

## Success metric

A user who already runs NixOS, or who left Arch Omarchy because of `pacman -Syu` pace, chooses `github:VirtualMachinist/Omahedron` over zicochaos/omarchy-nix, nixarchy, omanix, henrysipp/omarchy-nix, and omanixy.

A user on `omahedron-X.Y.Z` can sit down and use the same shell, menus, theme engine, bindings, and first-class agent surface as Arch Omarchy `vX.Y.Z`, with documented OS-layer gaps.

“Sit down” is measured on **bare metal**, lite-loaded, on hardware no more generous than the Hedronite Latitude 5420 (8 GB). Cloud-hosted Grok bots do not have to run on the laptop. Pixel claims from “Hyprland socket exists in QEMU” do not count.

“Chooses” also requires: a named pin README tells people to follow; a survivable first rebuild (documented Hyprland/Mesa cache); `omarchy.enable` meaning desktop-only unless a profile says otherwise; and a scorecard with no disqualifying loss per COMPETE §4.3.

## Analogy (and the limit of the analogy)

Rocky / Alma : CentOS  ::  Omahedron : Omarchy desktop.

Keep:

- Trailing blessed upstream versions, not HEAD
- Independent maintenance and governance
- Compatibility as a promise with a ledger
- No claim to be the upstream vendor
- Security patches follow immediately

Drop:

- “Same OS family / same installer / same kernel packages”
- Official support
- Marketplace entries that assume pacman or root writes to `/etc`

## In scope

- One Quickshell process and its plugins from `omarchy-src`
- Hyprland Lua bootstrap (≥0.56) + user overrides in `~/.config`
- Theme engine (TOML + templates) with live swap
- `omarchy-*` commands that are not package-manager or boot specific
- Default bindings
- First-run provisioning, Nix-seeded identity (`fullName` / `email`, fallback to NixOS user metadata)
- Fish as default interactive shell; bash as script runtime; opt-out allowed
- Omarchy-owned apps absent from nixpkgs, packaged under `pkgs/`
- Agent surface: Cursor and Grok must-match; Cline, OpenCode, Devin, OMP first-class
- Update flow: `omarchy update` / menu Update → `nix flake update` + `nixos-rebuild switch`
- Package install/remove from menus → flake package map + rebuild
- Compatibility ledger + CI allowlist for new binaries
- Channels named like official: `stable`, `rc`, `edge`
- Public flake consumption + Hedronite private hosts
- Profiles: `desktop` (default, thin) | `workstation` | `unfree.enable` (explicit)
- Flake locator: `$OMARCHY_NIX_FLAKE` then `/etc/nixos`; no scavenger home paths

## Destination (not v1 gate)

These stay in the product. They do not block `omahedron-4.0.2`.

- Webapps
- Remaining omarchy-owned apps
- Voxtype
- Fingerprint where the machine has a reader
- `omarchy-windows-vm` as wrap-or-stub once classified against v4.0.2 call sites
- Installer A: `omarchy setup` on an existing NixOS (humans do not open Nix)
- Installer B: Omahedron ISO (NixOS-shaped; systemd-boot + generations). Aim, not a current-tag gate.

## Out of scope (permanent unless an ADR says otherwise)

- Becoming official Omarchy
- Host pacman / yay / AUR / pkgs.omarchy.org
- Eating Omarchy’s pacman repo on the NixOS host
- Limine / Snapper / mkinitcpio UKI parity
- Official Omarchy Kernel / linux-ptl as Arch packages on the host
- Official Omarchy ISO; Arch `omarchy-apply-system` / `omarchy-apply-hardware` *chroot* (NixOS wraps of those command names are in scope — ADR-0025)
- Mutable `/usr/share/omarchy`, `omarchy-dev-link` as Arch implements it
- Omacom support or Foundation patronage features that assume Arch
- Plugin marketplace entries that install Arch packages or write `/etc` as root
- mise tarball toolchain under `/opt`
- Same-week Dell/Intel day-one kernels until they exist in Nix
- Tracking `quattro` HEAD on user-facing stable
- Reimplementing Quickshell / theme templates / script router in Nix
- The sibling brand Omarchanite

## Non-goals that people will request anyway

| Request | Answer |
|---|---|
| “Just install pacman on NixOS” | No. Two package managers on `/boot` is how you brick the box. Distrobox/nspawn is fine for userspace Arch tools, not the host kernel. |
| “Package linux_omarchy before 4.0.2 ships” | No. Kernel is a later track. Default is `boot.kernelPackages` from nixpkgs. |
| “Nix-native rice with Omarchy colors” | That is henrysipp / T00fy. Different product. |
| “1:1 including installer” | No Arch ISO / Limine / Snapper / UKI. Omahedron installer is NixOS-shaped (ADR-0025): setup on existing NixOS first, then our ISO. |
| “Call VM screenshots verified” | No. Latitude metal is the ship gate. |
| “`omarchy.enable` should match Arch’s full workstation image” | No. Desktop is thin. Workstation/unfree are profiles. |
| “Keep `~/omarchy-nix` as a flake locator” | No. That is zicochaos fork residue. |

## Release identity

- Do not invent a parallel 0.x scheme for the *desktop*.
- User-facing claim: `desktop = Omarchy X.Y.Z`, frozen YYYY-MM-DD, recorded in the module and the changelog.
- Flake tags: `omahedron-X.Y.Z`.
- This *repository’s* planning docs may say 0.1 — that is documentation maturity, not a desktop version.

## Target users

1. Hedronite daily driver (Dell Latitude 5420, 8 GB) and future NixOS hosts.
2. Public flake consumers who want Omarchy’s desktop on NixOS and will accept a COMPAT ledger.

Not a target: people who want official Omacom support, or people who want a from-scratch Nix Hyprland rice.

## Module defaults (ADR-0024)

`omarchy.enable = true` with `profile = "desktop"` ships the vendored tree, Hyprland + UWSM, Quickshell, live themes, SDDM (opt-out), PipeWire/NM/Bluetooth, Fish, and parseable stubs.

It does **not** enable Docker, Steam, Obsidian, Kdenlive, LibreOffice, mise-as-system-dev, zram at 100% RAM, or global `allowUnfree`. Those are `workstation` and/or `omarchy.unfree.enable = true`. Unfree stays easy; it is not a silent default.

## Constraints

- Vendor rule is load-bearing.
- 8 GB RAM lite dogfood is doctrine, not an apology.
- Security tags open a bump immediately.
- Thin desktop default is a competitive requirement (COMPETE §2.8).
- Treat zicochaos/omarchy-nix as glue upstream (rebase/overlay).
- One human maintainer; twelve directors orchestrate; subagents execute. Scope must fit that.
- NixOS 26.05 EOL is 2026-12-31. Pairing with 26.11 is a planned event, not a surprise.
- Do not say “best port” until COMPETE §4.5 allows.
