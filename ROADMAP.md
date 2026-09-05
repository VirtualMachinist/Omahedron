# ROADMAP.md

Phases are gates, not vibes. Maintainer moves a phase only when the exit checks are true.

## Now — working tree 0.1 (this drop)

Exit:

- [x] SPEC, DECISIONS, AGENTS, README
- [x] COMPAT skeleton, CHANNELS, UPSTREAM adapted to tag pins
- [x] schemas and checklists
- [ ] Hedronite git remote created (human)
- [ ] Directors given this tree as the constitution

## Next — stand up the port (`omahedron-4.0.2`)

Owner mix: Nix/CI, vendor, Schema, SecOps, UX/metal.

1. Fork zicochaos/omarchy-nix. Preserve license and credit.
2. Pin `omarchy-src` to GitHub tag `v4.0.2`.
3. Run [checklists/bump.md](checklists/bump.md) against that tag vs zicochaos’s last lock.
4. Fill [schema/scripts.lock.json](schema/scripts.lock.json) from `bin/` + call sites.
5. Fill [schema/packages.map.json](schema/packages.map.json) from `install/omarchy-*.packages`.
6. Make `nix flake check` fail on unclassified binaries.
7. Wrap update / install-remove to flake + rebuild (zicochaos already does most of this — verify against 4.0.2 menus).
8. VM pre-gate.
9. Latitude metal checklist, lite dogfood.
10. Tag `omahedron-4.0.2`. Changelog: “parity with Omarchy v4.0.2; known gaps: …”.

Exit: public module imports, Latitude session matches v4.0.2 desktop targets in SPEC, ledger complete for that tag.

Current implementation: pinned port, native full-system build, Fish/desktop/UX VM pre-gate, and direct script/package ledger enforcement are in place. Next is the Latitude metal checklist and lite dogfood; the product tag remains gated on that evidence. The package ledger explicitly retains seven unaudited optional hardware mappings. Diagnostic stub prefixes now follow ADR-0009; caller-required silence and exit codes remain tested exceptions.

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
