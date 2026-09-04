# Schema

Machine-readable ledgers so CI and agents share one vocabulary.

| File | Role |
|---|---|
| [schema/compat.schema.json](../schema/compat.schema.json) | JSON Schema for a COMPAT / script row |
| [schema/scripts.lock.json](../schema/scripts.lock.json) | every `omarchy-*` at the current pin |
| [schema/packages.map.json](../schema/packages.map.json) | upstream package name → nixpkgs / pkgs/ / stub |
| [schema/bump-record.schema.json](../schema/bump-record.schema.json) | one record per official tag bump |

## Classes (`scripts.lock.json`)

| class | On PATH? | Meaning |
|---|---|---|
| `vendor` | yes | shipped as-is from `omarchy-src` (shebang/path patches only) |
| `wrap` | yes | same command name, Nix stand-in body |
| `stub` | yes | exists so menus do not 404; prints parseable reason; exit ≠ 0 unless documented |
| `host` | optional | NixOS option owns the behavior; script removed or thin wrapper |
| `na` | no | must not appear; listed so agents do not “add it back” |
| `drop` | no | unreached distro tool, omitted from PATH; still inventoried |

`na` vs `drop`: `na` is a product promise (“we will not do pacman”). `drop` is an inventory fact (“this ISO helper is not called from the desktop”).

## Stub stdout

First line only, no decoration:

```
omahedron: stub: <reason-slug>
omahedron: na: <reason-slug>
```

Examples: `omahedron: na: pacman`, `omahedron: stub: windows-vm-phased`.

## Package map statuses

| status | Meaning |
|---|---|
| `nixpkgs` | use the nixpkgs attribute |
| `pkgs` | local derivation under `pkgs/<name>.nix` |
| `stub` | name exists in upstream list, not shipped |
| `exclude` | deliberately not shipped, with rationale |

zicochaos precedent for `pkgs` (re-verify at v4.0.2): aether, asdcontrol, omacalc, omacut, omawrite, tensaku, try, yaru-theme, hyprland-guiutils, hyprland-preview-share-picker, omarchy-nvim.

## CI contract (once the flake exists)

`nix flake check` must include:

1. Eval + module import
2. Existing zicochaos UX checks we keep
3. **Unknown binary tripwire:** union of `bin/omarchy-*` in the vendored tree minus keys in `scripts.lock.json` is empty
4. Optional: every `user-visible: true` row has class in `{vendor, wrap, stub, host}`

Schema owns the tripwire. vendor owns the patches that the tripwire forces.

## Generation

Until a generator exists, Schema updates JSON by hand during the bump. A later tool may scan `bin/` and fail if the lock is stale. Do not generate from COMPAT.md prose.
