# Credits

Omahedron is unofficial. It is not Basecamp, not 37signals, not Omacom, and not a supported Omarchy product.

## Desktop

The desktop the user sees is sourced from:

- [basecamp/omarchy](https://github.com/basecamp/omarchy) / [omacom/omarchy](https://github.com/omacom/omarchy)
- Site: https://omarchy.org
- License: MIT (confirm at each pin)

## Nix glue

The vendor-into-store architecture and a large part of the first module design come from:

- [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix)
- Especially `docs/UPSTREAM.md`, `pkgs/omarchy.nix`, NixOS + Home Manager modules, and the `omarchy-desktop` / `omarchy-ux` / `omarchy-fish` checks

Omahedron forks that work and adds release engineering: official tag pins, channel state machine, machine-readable COMPAT, security-first bumps, Latitude metal gate.

## Second reading

[fzakaria/nix-home](https://github.com/fzakaria/nix-home) `omarchy` branch uses the same vendor rule inside a personal flake. Useful as commentary. Not the base.

## Not the parity path

- [henrysipp/omarchy-nix](https://github.com/henrysipp/omarchy-nix) — reimplementation; author moved to Arch Omarchy
- [T00fy/omanix](https://github.com/T00fy/omanix) — Nix-native rice; no runtime theme switch
- [atqamz/omanixy](https://github.com/atqamz/omanixy) — narrower integration boundary, not a full script-tree port

## License

This working tree: MIT.

When the fork is created, keep upstream MIT text and add a NOTICE that names both Omarchy and zicochaos/omarchy-nix.
