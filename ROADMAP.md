# ROADMAP.md

Phases are gates, not vibes. Maintainer moves a phase only when the exit checks are true.

## Now — competitive bar (ADR-0024)

Exit for *calling ourselves the port to pick*:

- [x] SPEC, DECISIONS, AGENTS, README (public)
- [x] COMPAT + ledgers + CI fail-closed
- [x] Pin v4.0.2 + Latitude metal + git tag `omahedron-4.0.2`
- [x] [docs/COMPETE.md](docs/COMPETE.md) landed; AGENTS points at it
- [ ] Locator purge (`$OMARCHY_NIX_FLAKE` + `/etc/nixos` only)
- [ ] Thin `desktop` profile vs `workstation` / `unfree.enable`
- [ ] Rebase/overlay plan vs zicochaos `main` (Omarchy v4.0.3)
- [ ] Pin catch-up or dated deferral
- [ ] Nix verbs page + locator that matches or beats nixarchy
- [ ] Hyprland/Mesa substituter proven in install.md
- [ ] `schema/scorecard.json` checked in
- [ ] README rewrite; no “best” until COMPETE §4.5

Ordered queue and merge/tag gates: [docs/COMPETE.md](docs/COMPETE.md) §5 and §4.

## Landed — stand up the port (`omahedron-4.0.2`)

Fork of zicochaos/omarchy-nix, `omarchy-src` at v4.0.2, ledgers, VM pre-gate, Latitude metal, git tag `omahedron-4.0.2` @ `08e2f1d`. No GitHub Release yet. Package ledger still retains seven unaudited optional hardware mappings.

## Next + 1 — harden the rebuild (`4.0.2.x` / first security follow)

- Channel refs (`stable` / `rc` / `edge`) as documented in CHANNELS.md
- Bump record for any 4.0.3+ that appears
- Agent surface: Cursor + Grok launch paths proven on the Latitude
- COMPAT generated-from-schema or a check that prose and JSON cannot drift

## v1.1 — webapps and package completeness

- Webapp install/remove wraps that do not call pacman
- Remaining omarchy-owned apps not in nixpkgs
- Menu actions that were stubbed only for lack of packaging

## v1.2 — device extras

- Voxtype (classify first; stub if the stack is Arch-only)
- Fingerprint if the 5420 (or later metal) has a reader
- `omarchy-windows-vm` wrap-or-stub from actual call sites

## Later — kernel track (optional)

Only after two successful stable desktop bumps.

- Evaluate whether a `pkgs.linux_omarchy` from the same sources as official still makes sense
- If yes: `boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_omarchy`
- Never install a `.pkg.tar.zst` kernel on NixOS
- Separate pin from desktop HEAD

## Later — nixpkgs 26.11 cutover

Trigger: 26.11 released and Hyprland ≥0.56 plus Quickshell are sane on that pair. New ADR. Do not silently follow unstable.

## Never (unless an ADR supersedes)

- Host pacman
- Official ISO / Limine / Snapper / UKI parity
- Claiming Omacom support
- Tracking `quattro` on user `stable`
- Rewriting Quickshell in Nix
- Using the Omarchanite brand in this repo

## Watch items (not work items)

- Official Omarchy security tags
- Official kernel packaging story after 2026-09-03 (Omacom hire / linux-ptl model)
- zicochaos glue commits worth cherry-picking
- NixOS 26.05 EOL (2026-12-31)
- New `omarchy-*` on `quattro` that will land in the next tag
