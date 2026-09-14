---
name: omahedron-compat
description: >
  Use when an omarchy-* command is a stub, N/A, wrap, or host decline on
  Omahedron: omahedron: stub|na|wrap|host banners, pacman/yay/AUR, scripts.lock.json,
  packages.map.json, COMPAT classes. Not for writing Nix options in the large
  (nix-module) or rebuild (nix-rebuild).
---

# COMPAT / stubs

JSON ledgers win over prose. Source: Omahedron `schema/scripts.lock.json`, `schema/packages.map.json`. Human table: `docs/COMPAT.md`.

## Observe first

Run the command. **First line of stdout** (when it is a diagnostic stub):

```
omahedron: (stub|na|wrap|host): <reason>
```

Examples: `omahedron: stub: nixos-declarative`, `omahedron: na: pacman`. A human sentence follows. Ledger `class` + `reason` are authoritative — do not invent explanations.

Silent no-ops (e.g. some theme-set helpers) are listed in checks and print no banner.

## Classes

| class | Meaning | Agent does |
|---|---|---|
| `vendor` | Upstream body in packaged bin | Run it |
| `wrap` | NixOS adapter | Run it; still not pacman |
| `stub` | Declarative note or documented no-op | Read the option it names → **nix-module** → rebuild |
| `host` | NixOS owns the behavior | Set the NixOS option; do not reimplement the Arch script |
| `na` | Product exclusion (pacman, Limine/Snapper, `/usr/share/omarchy`, …) | Stop. Do not install host pacman |
| `drop` | Inventoried, omitted | Stop |

## Strategies

| Signal | Strategy |
|---|---|
| Banner names an option (`services.openssh.enable`, `omarchy.fingerprint.enable`, …) | Set that option; dry-activate |
| `na: pacman` / AUR / yay | `omarchy pkg add\|drop` or nixpkgs attr — never pacman |
| Menu path missing | Hidden = no NixOS implementation; do not recreate the Arch menu |
| Want to “just edit `/etc`” | Refuse. `/etc` is generated |

## Tool loop

1. Run (or read) the `omarchy-*` command. Capture line 1.
2. Match the banner regex. Look up `id` in `scripts.lock.json` if the reason is unclear.
3. If `stub`/`host`: edit the named option (**nix-module**). If `na`: stop.
4. Dry-activate (**nix-rebuild**). Do not work around a stub with imperative `/etc`, PAM, bootloader, or systemd-unit edits.

## Eval

After a stub-driven option change: dry-activate 0, and the stub still prints the same banner if re-run (stubs do not become wraps unless the port changes class in the ledger). The NixOS option is in effect (service/unit/package observable).

## Out of scope

Reclassifying ledger rows (port `AGENTS.md` + schema, same commit as the implementation). Desktop rice (`omarchy` skill).
