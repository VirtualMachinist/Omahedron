# Nix verbs on Omahedron

One map for the five Nix-facing operations nixarchy names explicitly. **Menu labels and command names stay `omarchy-*`** — there is no second product CLI on every pixel. The port-owned helpers (`omarchy-nix-*`) sit underneath the same Install, Remove, Update, and Package menus upstream ships.

See [install.md](install.md) for flake wiring, the Hyprland cache, and daily use. Stub reasons live in [COMPAT.md](COMPAT.md).

## Locator (G0)

Every mutating verb resolves your consumer flake the same way:

1. **`$OMARCHY_NIX_FLAKE`**, if set — a directory containing `flake.nix`, or the path to `flake.nix` itself.
2. **`/etc/nixos`**, if it contains `flake.nix` and a `nixosConfigurations."$(hostname)"` entry.

An explicit but invalid `OMARCHY_NIX_FLAKE` **fails closed** (nothing is mutated, no scavenger fallbacks). Set it once in your module when the flake is not under `/etc/nixos`:

```nix
environment.sessionVariables.OMARCHY_NIX_FLAKE = "/home/you/nixos-config";
```

Implementation: `omarchy-nix-pkglib` in the packaged tree (`share/omarchy/bin/omarchy-nix-pkglib`).

## The five verbs

| Verb | What the user sees | What runs | Effect |
|---|---|---|---|
| **Search** | **Install → Package** (launcher: `omarchy-launch-floating-terminal-with-presentation omarchy-nix-search`) | `omarchy-nix-search` | `fzf` over a cached nixpkgs index; picks batch into one `omarchy-nix-add` transaction. |
| **Add** | **Install → …** menu entries (`omarchy-install-*`) | `omarchy-nix-add <id…>` | Writes `<flake>/omarchy-packages.json`, then one locked `nixos-rebuild switch`. |
| **Remove** | **Remove → …** (or `omarchy-nix-remove` with no args for multi-select) | `omarchy-nix-remove [id…]` | Same JSON + one rebuild; interactive when called with no arguments. |
| **Apply** | (implicit after add/remove/update; also manual rebuilds) | `sudo nixos-rebuild switch --flake <resolved-flake>` | Activates the declarative config. Add/remove call this via `txn_rebuild`; you can run it yourself after hand-editing the flake. |
| **Update** | **Update → Omarchy** (`omarchy-update`) | `omarchy-update-system-pkgs` | `nix flake update` on the consumer flake, then the same rebuild as **apply**. |

Raw attributes work where the catalog does not: `omarchy-nix-add firefox` adds the nixpkgs attribute directly.

### Search details

- First run builds an index under `$XDG_CACHE_HOME/omarchy/nixpkgs-index-v2.tsv` (slow once).
- `omarchy-nix-search --refresh` rebuilds the index; successful adds refresh it in the background.
- `omarchy-nix-search --filter <term>` prints matching attribute names (no `fzf`).

There is no AUR path. **Install → AUR** opens `omarchy-nix-declarative-note`, which prints the NixOS declarative guidance (parseable stub banner + human text).

### Apply vs theme/runtime tools

**Apply** here means **switch the NixOS generation** — not Hyprland hot-reload alone. Runtime tools such as `omarchy-theme-set`, `omarchy-refresh-config`, and `omarchy-apply-lock` (stub on NixOS) are separate upstream commands; theme and monitor Nix options are *seeds* on first login, then files under `$HOME` are yours.

After editing `omarchy-packages.json` or your flake by hand, apply with:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#mybox
```

(use your hostname attribute and flake path).

### Update details

`omarchy-update` keeps upstream's logging, inhibitors, migrations, and post-update hooks. The NixOS package refresh core is `omarchy-update-system-pkgs`. If no consumer flake is found, it prints guidance and skips the refresh instead of touching the wrong checkout.

For a flake-only bump without the full update UX:

```sh
cd /etc/nixos && nix flake update && sudo nixos-rebuild switch --flake .#mybox
```

## Stub menus

Pacman-shaped helpers (`omarchy-pkg-*`, legacy install/remove entrypoints that upstream still names) are **stubs** on NixOS. They print a parseable first line:

```
omahedron: stub: nixos-declarative
```

then a short human sentence. Agents and CI match [COMPETE.md](COMPETE.md) §3.6. Prefer **Install → Package** (`omarchy-nix-search`) or declarative flake edits — not dead pacman menu paths as the happy path.

## Related docs

- [install.md](install.md) — first build, managed packages file, rollback
- [options.md](options.md) — `omarchy.managedPackagesFile`, profiles, themes
- [AGENTS-SURFACE.md](AGENTS-SURFACE.md) — stub contract and Lapis coexistence
- [CHANNELS.md](CHANNELS.md) — when the Omahedron input moves
