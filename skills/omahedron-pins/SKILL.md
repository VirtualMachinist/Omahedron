---
name: omahedron-pins
description: >
  Use when changing Omahedron release identity: omahedron-X.Y.Z tags, flake
  input URL, omarchy-src pin, stable/rc/edge channels, omarchy pin, omarchy
  channel, quattro HEAD. Not for nix flake update of unrelated inputs
  (nix-flake) or rebuild (nix-rebuild).
---

# Pins and channels

Omahedron trails official Omarchy **tags**. User stable does not track `quattro` HEAD. Cadence name: Omachron. Policy: `docs/CHANNELS.md`.

## Observe first

```bash
omarchy update pins
omarchy version channel
nix flake metadata "${OMARCHY_NIX_FLAKE:-/etc/nixos}"
```

Current tag, `omarchy-src` rev, and lock SHAs come from those commands. Do not invent them.

Last product git tag at handoff: `omahedron-4.0.2` (Omarchy v4.0.2). `feat/compete` may pin Omarchy v4.0.3 in the port repo — there is **no** `omahedron-4.0.3` user tag until metal + maintainer GO.

## Strategies

| Strategy | How | When |
|---|---|---|
| **stay** | do nothing | default |
| **pin-tag** | `omarchy pin omahedron-X.Y.Z` or set `inputs.omahedron.url = "github:VirtualMachinist/Omahedron/omahedron-X.Y.Z"` | user stable |
| **channel** | `omarchy channel set <tag>` | same as pin-tag; menu pixels stay `omarchy-*` |
| **update-in-pin** | `omarchy update` / `nix flake update omahedron` | still on the same claimed tag family after check |
| **edge** | `edge` follows `quattro` | **not** user stable; say so |

Never: host pacman channel TUI, `omarchy-dev-link`, tracking quattro on stable.

## Tool loop

1. Read pins (`omarchy update pins`, `flake metadata`).
2. Name the target tag. If it is not a published `omahedron-*` tag, stop (port repo work, not consumer).
3. Change **one** input (`omahedron`). Leave nixpkgs follows policy to **nix-flake**.
4. `nix flake check` then dry-activate (**nix-rebuild**).
5. Confirm `omarchy update pins` matches the claim.

Security tags on the same series (`v4.0.x`): no soak — bump when the port is check-green + metal-green. Minor/major: wait for the Omahedron tag.

## Eval

`omarchy update pins` shows the requested `omahedron-X.Y.Z` (or explicit channel). `flake.lock` `omahedron` / `omarchy-src` revs match that claim. `nix flake check` 0.

## Out of scope

Authoring a new port tag (repo `AGENTS.md` + COMPETE). Rebuild mechanics (nix-rebuild). Stub classes (omahedron-compat).
