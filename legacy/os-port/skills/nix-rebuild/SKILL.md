---
name: nix-rebuild
description: >
  Use when switching, testing, dry-running, or rolling back a NixOS generation
  on Omahedron: nixos-rebuild switch/test/boot/dry-activate, generations,
  omarchy rollback, sudo wrappers. Not for writing modules (nix-module), flake
  inputs (nix-flake), or failed-build forensics (nix-forensics).
---

# NixOS rebuild (Omahedron)

Activate the consumer flake. Humans may use `omarchy update` / `omarchy pkg add|drop` (they rebuild for you). Agents run rebuilds against the G0 flake — resolve it with **nix-flake** (`$OMARCHY_NIX_FLAKE`, then `/etc/nixos#$(hostname)`).

## Observe first

```bash
test -e /run/current-system
readlink -f /run/current-system
nixos-rebuild list-generations
printf 'flake=%s host=%s\n' "${OMARCHY_NIX_FLAKE:-/etc/nixos}" "$(hostname)"
```

Generation numbers and store paths come from those commands. Do not invent them.

Privileged apply uses `/run/wrappers/bin/sudo` (store `sudo` is not setuid).

## Strategies (pick one)

| Strategy | Command | When |
|---|---|---|
| **dry-run** | `sudo nixos-rebuild dry-activate --flake <flake>#<host>` | Default before any switch. odoom short-circuit: skip if the user already authorized a live switch. |
| **test** | `sudo nixos-rebuild test --flake <flake>#<host>` | Activate without adding a boot-menu generation. |
| **switch** | `sudo nixos-rebuild switch --flake <flake>#<host>` | Durable generation. Needs authorization. |
| **boot** | `sudo nixos-rebuild boot --flake <flake>#<host>` | Next reboot only. |
| **rollback** | `omarchy rollback` | Previous generation only. Does **not** roll back `$HOME`. |

`omarchy pkg add|drop` and `omarchy update` already call switch. Do not double-rebuild.

## Tool loop

1. Resolve the flake (nix-flake G0). Invalid `$OMARCHY_NIX_FLAKE` fails closed — do not scavenger-walk `$HOME`.
2. Read current generation (`readlink -f /run/current-system`, `list-generations`).
3. Dry-activate (or `nix flake check` if only eval is in doubt).
4. If traces fail → **nix-forensics**. Do not retry switch in a loop.
5. On authorization: switch/test/boot. Confirm a new generation (switch/boot) or that `/run/current-system` moved (test/switch).
6. Rollback path: `omarchy rollback --list`, then `omarchy rollback`. Tell the user `~/.config` is unchanged.

```bash
sudo nixos-rebuild dry-activate --flake /etc/nixos#"$(hostname)"
sudo nixos-rebuild switch --flake /etc/nixos#"$(hostname)"
omarchy rollback --list
```

## Eval

- Dry-run: command exits 0.
- Switch: new generation in `list-generations` and `/run/current-system` is a new store path.
- Rollback: previous generation is current; `$HOME` files untouched.

## Out of scope

Writing `omarchy.*` / flakes (nix-module, nix-flake). Failed eval traces (nix-forensics). Desktop rice (`omarchy` skill).
