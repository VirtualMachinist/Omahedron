# Schema

Machine-readable ledgers so CI and agents share one vocabulary. Update the ledger and its implementation in the same commit.

| File | Role |
|---|---|
| [compat.schema.json](../schema/compat.schema.json) | JSON Schema for a script row |
| [scripts.schema.json](../schema/scripts.schema.json) | Whole script-ledger schema |
| [scripts.lock.json](../schema/scripts.lock.json) | Every pinned upstream bin command, permanent pacman policy, and explicit port helpers |
| [packages.schema.json](../schema/packages.schema.json) | Whole package-map schema |
| [packages.map.json](../schema/packages.map.json) | Exact upstream install-list inventory and explicit entries outside those lists |
| [bump-record.schema.json](../schema/bump-record.schema.json) | One record per official tag bump |

## Script classes

| class | In packaged bin? | Meaning |
|---|---|---|
| `vendor` | yes | Upstream body; only interpreter, store-root and sudo-wrapper paths may differ |
| `wrap` | yes | Port adapter or upstream command with further NixOS patches |
| `stub` | yes | Replaced behavior: declarative guidance or a documented predicate/no-op |
| `host` | optional | NixOS owns behavior; absent command or thin adapter |
| `na` | no | Explicit product exclusion, including host pacman |
| `drop` | no | Inventoried upstream command deliberately omitted |

`vendor` describes the command body, not the success of every downstream call. An upstream installer may remain vendor-class while its package helper is a stub. The ledger notes this limitation. `user_visible` is a reviewed reachability annotation; CI rejects absent commands marked visible, but does not prove every dynamic menu/call path.

`scripts` contains the upstream inventory plus the permanent `pacman` policy row. `port_scripts` separately inventories the five `omarchy-nix-*` helpers implemented in `pkgs/omarchy.nix`. Generated hidden wrapper internals are not public commands. `since_pin` records when the row was first classified. `phase` retains the target for full workflow support; a retained vendor body can still have a later phase. Executable bits are checked against `executable` (default true). The sourced Bash library is intentionally non-executable. The missing upstream executable bits on `omarchy-remove-service-dropbox` are repaired at package time.

Diagnostic stubs start with `omahedron: stub: <reason>` as required by ADR-0009, followed by NixOS guidance. Their existing exit codes remain unchanged. The AUR-availability predicate, missing-package predicate and browser-theme no-op stay silent; update availability prints the prefix only for a TTY or verbose invocation. Snapshot argument errors print usage to stderr. `checks.omarchy-ledgers` executes all classified stubs in a temporary home with no desktop session environment, checking prefixes, exit codes, required silence and unchanged user state.

## Package map

| status | Meaning |
|---|---|
| `nixpkgs` | Dotted attribute in the pinned consumer Nixpkgs evaluates to a derivation |
| `pkgs` | Named flake package backed by `pkgs/<attr>.nix` |
| `host` | Listed NixOS options own the service, firmware, driver or OS equivalent |
| `gap` | No audited mapping yet; notes describe the unsupported surface |
| `exclude` | Deliberately outside the shipped scope, with rationale |

Package rows have `sources` listing every upstream `install/*.packages` file containing that name. CI checks names and source membership in both directions. `extra_packages` explicitly holds entries outside those lists (port packages, Fish, and the cups-browsed exclusion); each cites repository evidence. These entries cannot overlap the upstream inventory. All exported flake packages except the `default` alias must be covered; Nix manifest attrsets are not packages.

Attribute rows also have `availability`:

- `default`: the evaluated default module includes that package name in `environment.systemPackages`, `fonts.packages` or `boot.plymouth.themePackages`. Name comparison accommodates intentional overrides such as mpv with MPRIS; it is not a version/derivation-identity assertion. Consumers can override the defaults.
- `available`: the attribute evaluates, but CI makes no default-installation claim. Notes identify plugin dependencies or consumer-selected counterparts.

`host` verifies that each option exists; notes describe defaults or opt-ins. The existing module checks cover policy defaults. Neither an available attribute nor a host option is hardware support evidence. Seven optional upstream hardware entries remain explicit `gap` rows. The map is not an inventory of every transitive Nix dependency or every optional Install-menu item; the latter has its own `catalog-consistency` check.

## Enforced CI contract

Run:

```sh
nix build -L .#checks.x86_64-linux.omarchy-ledgers
```

The check is in `nix flake check` and the ordinary PR/push workflow. It validates both JSON schemas offline, rejects duplicate keys/rows and unknown fields, and compares ledger pins/revisions with `flake.lock` and the evaluated source. A new upstream command fails even if it contains no system mutation pattern. Stale rows, unclassified port helpers, missing packaged commands, vendor-body drift and disagreement with the runtime manifest also fail.

Nix probes force every mapped attribute's `drvPath` under the default consumer module's package policy, verify default membership and option existence, and pass context-free evidence to Python. This does not build the full desktop closure. The check builds the vendored Omarchy package for body inspection and runs mutation tests against copied real inputs. Existing runtime, migration, catalog and VM checks remain complementary.

The ledgers are hand-reviewed (`generated: false`). On a bump, read the new source inventory, review adaptations and update mappings; do not automatically classify new names or generate policy from COMPAT prose. The validator deliberately does not prove semantic equivalence of wrap bodies or generate the human COMPAT tables.
