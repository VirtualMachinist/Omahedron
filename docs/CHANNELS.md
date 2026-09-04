# Channels

Official Omarchy names channels `stable`, `rc`, `edge`, and `dev`. Omahedron mirrors the first three. We do not advertise a fourth user channel.

## Refs (once the flake exists)

Proposed flake outputs / branches. Do not invent others.

| Channel | Branch or ref | `omarchy-src` | nixpkgs | Home Manager | Default for users |
|---|---|---|---|---|---|
| stable | `stable` + tags `omahedron-X.Y.Z` | official tag `vX.Y.Z` | nixos-26.05 (until cutover ADR) | release-26.05 | yes |
| rc | `rc` | official RC tag when one exists | same as stable unless blocked | matching | no |
| edge | `edge` | `quattro` (or master if they move default) | nixos-unstable | master | no |

`dev` in official language maps to our `edge`. Do not create both.

## State machine

```
watching  --(tag exists, policy says go)-->  bump-open
bump-open --(flake check + ledger)------->  check-green
check-green --(Latitude metal)----------->  metal-green
metal-green --(tag + changelog)---------->  tagged
```

Owners: Merci moves `watching` → `bump-open` when the tag is observed. Marci/Lea drive to `check-green`. Sati signs `metal-green`. Leo tags. Vini can force `bump-open` on a security note even if Merci is asleep.

## Policy

### Security / patch tags (`v4.0.1`, `v4.0.2`, future `vX.Y.Z` on the same series)

- Event: GitHub release published, or official notes call it security.
- Soak: **none**.
- Ship when check-green and metal-green.

### Minor / major (`v4.1.0`, `v5.0.0`)

- Event: release tag exists.
- Soak: only while a newer patch on that series is still landing. Example at handoff: v4.0.0 (2026-08-14) → v4.0.1 (2026-08-25) → v4.0.2 (2026-08-31). A rebuild that pinned 4.0.0 on 4.0.0 day would have been wrong. Wait for the train to stop, not for a calendar month.

### edge

- Always behind a warning: not 1:1, not supported, maintainer dogfood only.
- May use nixos-unstable and a newer Hyprland input.
- Never the default in README snippets.

### rc

- Exists only when official publishes an RC tag.
- Dogfood on a NixOS VM generation (Mac mini/Studio), not on the Latitude daily driver.
- Promote by pinning the final stable tag, not by renaming edge.

## What users see in the module

When the module exists it must declare, in one place:

```
desktop = Omarchy X.Y.Z
frozen  = YYYY-MM-DD
channel = stable | rc | edge
```

Leo’s changelog line:

```
parity with Omarchy vX.Y.Z; known gaps: …
```

## Update command mapping

| Official | Omahedron |
|---|---|
| `Update > Omarchy` / `omarchy update` | `nix flake update` of the consuming flake + `nixos-rebuild switch` (and HM if split) |
| Channel switcher as Arch implements it | change the Omahedron input ref; rebuild. The Arch TUI channel switcher is `na` or stub |
| `omarchy-update-system-pkgs` | wrap or stub; never pacman |

## Suggested consumer pin

```nix
# once the public remote exists
omahedron.url = "github:Hedronite/omahedron/omahedron-4.0.2";
# or follow the stable branch after it exists
# omahedron.url = "github:Hedronite/omahedron/stable";
```

Hedronite org/remote spelling is TBD at remote-creation time. Do not bikeshed it in glue PRs.
