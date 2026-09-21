---
name: nix-flake
description: >
  Use when locating or editing the Omahedron consumer flake: G0 locator,
  OMARCHY_NIX_FLAKE, flake.nix, flake.lock, inputs.follows, nix flake
  check/update/show, pin vs follow. Not for nixos-rebuild itself (nix-rebuild)
  or omarchy.* option edits (nix-module).
---

# Consumer flake (G0)

One flake per host. This skill owns **where it is** and **how inputs move**. Pin identity is **omahedron-pins**.

## Observe first

```bash
printf 'OMARCHY_NIX_FLAKE=%s host=%s\n' "${OMARCHY_NIX_FLAKE-}" "$(hostname)"
ls -l "${OMARCHY_NIX_FLAKE:-/etc/nixos}/flake.nix" "${OMARCHY_NIX_FLAKE:-/etc/nixos}/flake.lock"
nix flake metadata "${OMARCHY_NIX_FLAKE:-/etc/nixos}"
nix flake show "${OMARCHY_NIX_FLAKE:-/etc/nixos}"
```

Lock SHAs and input URLs come from `flake metadata` / `flake.lock`. Do not invent them.

## G0 locator

1. `$OMARCHY_NIX_FLAKE` — directory containing `flake.nix`, or the path to a file named `flake.nix`.
2. `/etc/nixos` when `nixosConfigurations."$(hostname)"` exists.

Explicit but invalid `$OMARCHY_NIX_FLAKE` **fails closed**. No `~/Omahedron`, `~/omarchy-nix`, or other scavenger paths.

Set the locator in the module when the flake is not under `/etc/nixos`:

```nix
environment.sessionVariables.OMARCHY_NIX_FLAKE = "/home/you/nixos-config";
```

## Strategies

| Strategy | What | Eval |
|---|---|---|
| **check** | `nix flake check <flake>` | exits 0; use before update/switch |
| **show** | `nix flake metadata` / `show` | print current inputs; no mutation |
| **update-all** | `nix flake update` then **nix-rebuild** | lock file changed; then dry-activate |
| **update-one** | `nix flake update omahedron` (or `nixpkgs`) | only that input moved |
| **follow** | `omahedron.inputs.nixpkgs.follows = "nixpkgs"` | only when consumer nixpkgs **is** nixos-26.05; else leave unfollowed (Omahedron packages stay on the tested nixpkgs) |
| **pin** | change `inputs.omahedron.url` to a tag — **omahedron-pins** | lock matches the claimed tag |

`omarchy update` is the human-facing full flow (pins print, then update + rebuild). Agents may run `nix flake update` on the resolved flake, then rebuild via nix-rebuild.

## Tool loop

1. Resolve G0. Read `flake.nix` and `flake.lock` (current bytes, like odoom `read_nixpkgs_file`).
2. `nix flake metadata` for live input SHAs.
3. `nix flake check` before any lock rewrite.
4. Mutate one strategy only (update-one vs pin vs follow).
5. `nix flake check` again. Then dry-activate (**nix-rebuild**).
6. Do not track `quattro` HEAD on user stable (**omahedron-pins**).

## Eval

`nix flake check <resolved-flake>` exits 0. After update, `flake.lock` diff is real (git or `nix flake metadata` before/after). Hostname attr exists: `nix flake show` lists `nixosConfigurations.<hostname>`.

## Out of scope

`nixos-rebuild` (nix-rebuild). `omarchy.*` option bodies (nix-module). Channel policy (omahedron-pins).
