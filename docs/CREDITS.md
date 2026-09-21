# Credits

Omahedron is an unofficial theme pack for Omarchy. It is not Basecamp, not 37signals, not Omacom, and not a supported Omarchy product.

The themes in `themes/` are Hedronite's. Omarchy's theme engine, documented in upstream `docs/theming.md`, is what applies them.

## Desktop (archived port)

The desktop the user sees is sourced from:

- [basecamp/omarchy](https://github.com/basecamp/omarchy) / [omacom/omarchy](https://github.com/omacom/omarchy)
- Site: https://omarchy.org
- License: MIT (confirm at each pin)

## Nix glue (archived port)

The desktop port under `legacy/os-port/` vendored Omarchy into the Nix store. That architecture and a large part of the first module design come from:

- [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix)
- Especially `docs/UPSTREAM.md`, `pkgs/omarchy.nix`, NixOS + Home Manager modules, and the `omarchy-desktop` / `omarchy-ux` / `omarchy-fish` checks

That port added release engineering on top: official tag pins, a channel state machine, a machine-readable COMPAT ledger, and security-first bumps. Since 2026-09-12 (ADR-0026) Omahedron owns that glue. Since 2026-09-21 (ADR-0027) it lives in `legacy/os-port/` and is not the product. zicochaos/omarchy-nix stays historical provenance: credited here and in LICENSE.

## Second reading

[fzakaria/nix-home](https://github.com/fzakaria/nix-home) `omarchy` branch uses the same vendor rule inside a personal flake. Useful as commentary. Not the base.

## Not the parity path

- [henrysipp/omarchy-nix](https://github.com/henrysipp/omarchy-nix) — reimplementation; author moved to Arch Omarchy
- [T00fy/omanix](https://github.com/T00fy/omanix) — Nix-native rice; no runtime theme switch
- [atqamz/omanixy](https://github.com/atqamz/omanixy) — narrower integration boundary, not a full script-tree port

## License

This working tree: MIT.

This tree is MIT. LICENSE names both Omarchy and zicochaos/omarchy-nix.
