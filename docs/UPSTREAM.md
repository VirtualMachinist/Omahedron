# Upstream

Philosophy and bump procedure. Adapted from zicochaos/omarchy-nix `docs/UPSTREAM.md`, rewritten for **tag pins** instead of tracking `quattro` HEAD.

Read this before changing anything the user can see.

## What Omarchy is

Official project: DHH / 37signals / Omacom. Site: https://omarchy.org  
Source: https://github.com/basecamp/omarchy (also omacom/omarchy)

Facts at 2026-09-04:

- Quattro = 4.x. v4.0.0 shipped 2026-08-14. Follow-ups v4.0.1, **v4.0.2** (latest stable).
- Stack: Arch + Hyprland (≥0.56, Lua) + one Quickshell process + ~383 `omarchy-*` bash scripts + TOML/sed theme engine.
- `$OMARCHY_PATH` is the root (Arch: `/usr/share/omarchy`).
- Packaging: pacman + pkgs.omarchy.org. Channels: stable, rc, edge, dev. New installs start on stable.
- Omacom funds infrastructure. 2026-09-03 hire: Krzysztof Wilczyński to lead “Omarchy Kernel” — still Linux, branded/custom package, not a new kernel family.
- linux-ptl exists as an Arch PKGBUILD for specific hardware. Default boxes use stock Arch linux.

Manual worth reading: https://omarchy.org/manual — Updates, Security, Dotfiles.

## Vendor philosophy

Reproduce upstream behavior. Diffs are NixOS-isms or known gaps, not features.

- Two-space indent in vendored files we touch only via substitute
- `#!/bin/bash` shebangs on scripts
- `omarchy-` prefixed commands
- `$OMARCHY_PATH` as truth
- `pkexec` for privilege unless NixOS owns the unit
- Do not rewrite Quickshell, theme templates, or the script router

## Translate, do not vendor

| Upstream | Omahedron stand-in |
|---|---|
| pacman / yay / pkgs.omarchy.org | flake packages + `schema/packages.map.json` → rebuild |
| `omarchy update` | `nix flake update` + `nixos-rebuild switch` |
| Limine + Snapper + UKI | systemd-boot + Nix generations |
| linux / linux-ptl / Omarchy Kernel | `boot.kernelPackages`; optional custom derivation later |
| `omarchy-apply-hardware` | NixOS hardware + firmware modules |
| mise / `/opt/packages` | nixpkgs / flakes / devshells |
| ISO chroot | module + HM activation |

## Bump procedure (every official stable tag)

Schema records a bump file from [templates/bump-record.md](../templates/bump-record.md).

1. Note old pin and new tag. Diff at least:
   - `bin/`
   - `default/`
   - `themes/`
   - `shell/`
   - `install/omarchy-*.packages`
   - `default/omarchy/omarchy-menu.jsonc`
   - `default/systemd/user/`
   - `default/agents/skills/` if present
2. `nix flake lock --update-input omarchy-src` to the **tag**, not `quattro`.
3. `nix flake check` — failed `--replace-fail` is expected. Fix or drop with a COMPAT note.
4. Mutation greps (from zicochaos, keep these):
   - `grep -rn 'cp ' "$SRC/bin/" | grep '\$OMARCHY_PATH'`
   - `grep -rn '/usr/\|/etc/pacman\|pacman ' "$SRC/bin/" | grep -v '^.*#'`
5. Update `schema/packages.map.json` for new package names.
6. Update `schema/scripts.lock.json` for new or removed `omarchy-*`. CI must go red on unknowns.
7. Sync theme count and `appPackages` lists across README, options, flake.
8. Re-check menu rewires vs `expected_removes`.
9. VM pre-gate.
10. Latitude metal: [checklists/metal.md](../checklists/metal.md).
11. Tag `omahedron-X.Y.Z`. Changelog names gaps.

One upstream rev + glue fixes = one commit (or one PR stacked as that logical commit). Do not mix a theme rewrite with a pin.

## zicochaos delta to remember on the first pin

Their public tree tracked `quattro`, vendored `version` still `4.0.0.alpha`, last public snapshots 2026-08-18. Official v4.0.1 and v4.0.2 security work landed after that. The first Omahedron bump is not “lock update.” It is “catch the security tags and stop following HEAD.”

## Upstream URLs

- https://omarchy.org
- https://omarchy.org/manual/updates
- https://omarchy.org/news/2026/09/omacom-foundation-hires-krzysztof-wilczynski/
- https://github.com/basecamp/omarchy
- https://github.com/basecamp/omarchy/releases/tag/v4.0.2
- https://github.com/omacom/omarchy-pkgs (linux-ptl PKGBUILD)
- https://github.com/zicochaos/omarchy-nix
- https://github.com/zicochaos/omarchy-nix/blob/main/docs/UPSTREAM.md
- https://github.com/henrysipp/omarchy-nix (historical only)
