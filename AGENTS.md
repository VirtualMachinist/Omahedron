# AGENTS.md

Operating manual for maintainers and coding agents working in this repository.

Read this entire file before writing code or docs. Do not reopen questions that are settled in [DECISIONS.md](DECISIONS.md) unless new facts contradict them. New facts go into a new ADR, they do not silently overwrite.

## What this repo is

Omahedron: trailing-stable Omarchy desktop on NixOS. Public flake intended for daily-driver use. Unofficial. Desktop parity, not distro parity.

Upstream product: https://github.com/basecamp/omarchy  
Port architecture we adopt: https://github.com/zicochaos/omarchy-nix  
Public remote: https://github.com/VirtualMachinist/Omahedron  
First pin: Omarchy **v4.0.2**.

## Source of truth (by domain, not by rank)

Conflicts are reconciled by domain. Do not invent a “SPEC always wins” hammer.

| Domain | Winner | Artifact |
|---|---|---|
| Desktop behavior the user can see | Pinned `omarchy-src` | vendored tree + cite `bin/…`, `default/…`, `themes/…`, `shell/…` |
| OS correctness (boot, store, privileges, two bootloaders) | NixOS | modules + COMPAT class `host` / `wrap` / `stub` / `na` |
| Release identity (what we claim to ship) | Channels policy + lockfile | [docs/CHANNELS.md](docs/CHANNELS.md), `flake.lock` |
| Script classification | Ledger | [schema/scripts.lock.json](schema/scripts.lock.json) |
| Package classification | Map | [schema/packages.map.json](schema/packages.map.json) |
| Everything else | An ADR | [DECISIONS.md](DECISIONS.md) + [templates/adr.md](templates/adr.md) |

When desktop behavior and OS correctness collide, the answer is a ledger row — not a rewrite and not a fake pacman.

Code and the ledger that describes it change in the **same commit**.

## Voice

- Prefer small diffs and documented stubs over clever Nix abstractions.
- When unsure whether something is desktop or distro, classify it and stub. Do not guess implement.
- Cite upstream files (`bin/omarchy-…`, `default/hypr/…`) when adapting.
- Do not invent a parallel 0.x version scheme. User-facing versions are Omarchy `vX.Y.Z` and flake tags `omahedron-X.Y.Z`.
- Do not spend time on political or community drama around DHH or Hyprland.
- If official Omarchy changes the kernel or packaging story after 2026-09-03, re-verify before assuming linux-ptl is still the model.
- Bare-minimum hardware is canonical doctrine. If it works on the 8 GB Latitude, it works elsewhere. Lite dogfood: tools installed, not all loaded.

## What you must not do

- Reimplement Quickshell widgets, theme templates, or the script router in Nix
- Install host pacman to “pull future Omarchy Arch packages”
- Track `quattro` HEAD on user-facing `stable`
- Claim 1:1 OS / kernel / installer parity
- Mix two bootloaders or two module trees
- Daily-drive only in a non-passthrough VM and call UX verified
- Block a stable desktop tag on `linux_omarchy`
- Use the brand **Omarchanite** in this repo (reserved)
- Rename the product away from **Omahedron** in passing

## Roles (this repo)

Private fleet runbooks and named operator cards live **outside** this repository. In-tree work uses role titles only:

### Maintainer

Owns: work sequencing, freeze/thaw of decisions, who may change what, vendor/agent-glue scope when it touches this tree.

Does: open bump work items, stop scope fights, refuse drive-by flakes.

Does not: silently overwrite ADRs.

### Nix/CI

Owns: NixOS module, HM module, flake outputs, channels as refs, CI eval.

Does: keep `$OMARCHY_PATH` honest, session PATH, activation, pairing with nixpkgs stable.

Does not: restyle the bar.

### SecOps

Owns: security-tag response, stub honesty, “no host pacman”, sshd/sudo/polkit notes in COMPAT.

Does: treat official 4.0.x security notes as a bump-open event with no soak.

Does not: ship a “temporary” ALPM root.

### UX/metal

Owns: what the user sees. Theme render, menus, first-run feel, metal checklist truthfulness.

Does: refuse VMSVGA “it looked fine.”

Does not: accept screenshots from QEMU software framebuffer as ship evidence.

### Schema

Owns: `schema/*`, inventories, bump records, generated-vs-hand COMPAT consistency.

Does: fail CI when a new `omarchy-*` appears unclassified.

Does not: leave ledger rows as prose-only.

### Publishing

Owns: README banner, CHANGELOG, credits, “we are not official” language.

Does: every shipped tag gets “parity with Omarchy vX.Y.Z; known gaps: …”.

Does not: claim Omacom support.

## Coding agents (Cursor, Cline, cloud composers, …)

You inherit this file. You do not get a private constitution. If informal guidance and this file disagree, this file plus DECISIONS.md win and you stop to ask the Maintainer.

Before any patch:

1. Name the domain (desktop / OS / release / ledger / other).
2. Point at the artifact you will change.
3. If classification is required, edit `schema/scripts.lock.json` or `schema/packages.map.json` in the same change.

## Implementation gate

Public remote is `github:VirtualMachinist/Omahedron`. Pin work already lands on `main` (Omarchy **v4.0.2**). Before any `omahedron-4.0.2` tag:

1. Keep `omarchy-src` on the claimed pin; do not track `quattro` HEAD on user-facing stable.
2. Run [checklists/bump.md](checklists/bump.md) on bump.
3. Keep `schema/scripts.lock.json` aligned with that tag’s `bin/`.
4. Metal on the Latitude before the product tag.

Do not start from henrysipp/omarchy-nix. Do not start from T00fy/omanix.

## Review questions (paste into PRs)

- Does the user see upstream pixels and bindings, or a Nix rewrite?
- Is every new `omarchy-*` classified?
- Did `--replace-fail` break, and was that fixed or dropped with a COMPAT note?
- Was UX signed off on the Latitude, or only in a VM?
- Does the changelog name gaps?
