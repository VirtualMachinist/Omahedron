---
name: nix-module
description: >
  Use when editing Omahedron consumer Nix: configuration.nix, omarchy.*
  options, omarchy-packages.json, mkIf/mkMerge/mkForce, home-manager.users,
  hardware-configuration.nix (read-only). Not for flake inputs (nix-flake) or
  running nixos-rebuild (nix-rebuild).
---

# Consumer module edits

Agents edit Nix. Humans use `omarchy` verbs. Read `/etc/omahedron/AGENTS.md` on the host.

## Observe first

```bash
# G0 from nix-flake, then:
sed -n '1,200p' "${OMARCHY_NIX_FLAKE:-/etc/nixos}/configuration.nix"
sed -n '1,120p' "${OMARCHY_NIX_FLAKE:-/etc/nixos}/hardware-configuration.nix"
test -f "${OMARCHY_NIX_FLAKE:-/etc/nixos}/omarchy-packages.json" \
  && cat "${OMARCHY_NIX_FLAKE:-/etc/nixos}/omarchy-packages.json"
```

Option names and current values come from those files and from `docs/options.md` in the Omahedron source — not from memory.

## What you may edit

| Artifact | Role |
|---|---|
| `flake.nix` | inputs / G0 — **nix-flake** / **omahedron-pins** |
| `configuration.nix` | `omarchy.*`, imports, extra NixOS options |
| `omarchy-packages.json` | menu-managed packages (`omarchy pkg add\|drop` writes this) |
| `home-manager.users.<name>` | user session defaults |

**Read-only:** `hardware-configuration.nix`. Never regenerate or clobber it. `omarchy setup` copies it once.

`$OMARCHY_PATH` and `/nix/store` are read-only. Do not restyle Quickshell or Hyprland in Nix.

## Strategies

| Intent | How | Notes |
|---|---|---|
| Identity / profile / unfree / terminal / fingerprint / autologin | Prefer `omarchy setup …` (writes `omarchy.*` + rebuild) | Agent may set the same option in `configuration.nix` if the verb is wrong |
| Add/drop a catalog or nixpkgs attr | `omarchy pkg add\|drop` or edit `omarchy-packages.json` | One transaction, one rebuild |
| Enable a NixOS service the stub names | Set that option (`services.openssh.enable`, …) | **omahedron-compat** — do not write `/etc` by hand |
| Override a default | `lib.mkForce` / `mkMerge` / `mkIf` | Read the current assignment first |

`omarchy.*` lives in Omahedron `config.nix` (shared NixOS + HM). HM reads `osConfig.omarchy`. Thin default profile is `desktop`; `workstation` and unfree are opt-in.

## Tool loop

1. Read the current module file (odoom: always `read_nixpkgs_file` first).
2. Name the option or JSON key you will change. If a stub printed an option, use that name.
3. Smallest diff. Do not rewrite the whole flake.
4. `nix flake check` then dry-activate (**nix-rebuild**).
5. Type errors / infinite recursion / option collision → **nix-forensics**.

## Eval

The option evaluates (`nix flake check` or dry-activate). `hardware-configuration.nix` git/mtime unchanged. Observable behavior matches the option (service running, package on PATH, profile switched) — a successful parse is not enough.

## Out of scope

Rebuild commands (nix-rebuild). Input pins (omahedron-pins). Stub honesty (omahedron-compat). Desktop files under `~/.config` (`omarchy` skill).
