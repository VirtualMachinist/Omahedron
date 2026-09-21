# omahedron-4.0.3

parity with Omarchy v4.0.3; known gaps: pacman/yay/AUR, official kernel packages, Limine/Snapper/UKI, ISO apply-system/hardware, mutable /usr/share/omarchy, Omacom support, Arch plugin installs. See docs/COMPAT.md.

## Desktop

- Vendored omarchy-src `v4.0.3` (`0534987009061cbe2dacdde4ad564092ab698d12`).
- Hyprland v0.56.2. NixOS 26.05.

## Glue

- oma-cli workstream 1–5 on `main` (PR #22): honest `omarchy` help, installer A (`omarchy setup`), identity/pkg/rollback/update wraps, `/etc/omahedron/AGENTS.md`.
- Compete G0–G8 closed on `main`. Thin desktop default unchanged.

## Metal

- Latitude 5420 (lathe) GO-B 2026-09-15: pin `b85b8f3` + this tag. Generation 24. Running `omarchy` 4.0.3. Host kitty `/etc` extra absorbed so 4.0.3 can vendor `xdg/kitty/kitty.conf`.

## Security

- Patch/security train vs 4.0.2; no soak (CHANNELS policy).

## Ledger

- Pin `schema/pin.json` state `tagged`. Command/package counts as on `main` at tag.
