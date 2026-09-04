# DECISIONS.md

Architecture decision records. Append only. Supersede with a new ADR; do not silently edit the accepted block of an old one.

Template: [templates/adr.md](templates/adr.md).

---

## ADR-0001 — Product name and brands

- Status: accepted
- Date: 2026-09-04
- Deciders: human maintainer / Maintainer role

**Decision.** The distro/product name is **Omahedron**. The org is **Hedronite**. The reserved sibling brand **Omarchanite** is not used in this repository (it will be some other substrate: Home Manager-only overlay, CLI, or deploy tool — TBD). The generic category phrase “nix-omarchy” may appear in prose as a descriptor, never as the product name.

**Why.** Need a public name that is not official Omarchy, and a stable identifier for the fleet.

**Consequences.** Flake tags are `omahedron-X.Y.Z`. Module namespace stays `omarchy.*` where we inherit zicochaos options, unless a later ADR renames options (do not rename in v1; it costs consumers for no desktop gain).

---

## ADR-0002 — Rocky / Alma posture

- Status: accepted
- Date: 2026-09-04

**Decision.** Market and operate as an independently maintained trailing-stable *rebuild of the Omarchy desktop* on NixOS. Never as official Omarchy, never as 1:1 OS/kernel/installer parity.

**Why.** Matches the real work and keeps agents from “completing” pacman or Limine.

**Consequences.** README banner and changelog always name gaps. Publishing owns the sentence.

---

## ADR-0003 — Base tree

- Status: accepted
- Date: 2026-09-04

**Decision.** Fork and improve [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix). Do not start from henrysipp/omarchy-nix, T00fy/omanix, atqamz/omanixy, or fzakaria/nix-home (the last is a useful second reading of glue only).

**Why.** zicochaos already vendors upstream Quattro, NixOS + HM modules, `$OMARCHY_PATH` in the store, `--replace-fail`, UX checks, and an UPSTREAM bump checklist. The differentiator is release engineering (tag pins, ledger, channels, metal gate), not a rewrite.

**Consequences.** First implementation commit is that fork plus pin to v4.0.2. Credit is mandatory ([docs/CREDITS.md](docs/CREDITS.md)). Useful glue patches may be offered back. Their `quattro` HEAD is not our `stable`.

---

## ADR-0004 — First stable pin

- Status: accepted
- Date: 2026-09-04

**Decision.** First user-facing pin is official Omarchy tag **v4.0.2** (2026-08-31, `346e69e` on GitHub at handoff). Flake tag `omahedron-4.0.2` after checks + Latitude metal.

**Why.** Latest official stable at decision time. 4.0.1 and 4.0.2 are security-heavy. zicochaos public snapshots through 2026-08-18 predate those tags and still tracked `quattro` with `version` = `4.0.0.alpha`.

**Consequences.** Do not ship “feature-complete vs zicochaos README” as if that were v4.0.2.

---

## ADR-0005 — Channels and lag

- Status: accepted
- Date: 2026-09-04

**Decision.** Channel names match official: `stable` (default), `rc`, `edge`. Lag is an event state machine, not a week count.

States: `watching` → `bump-open` → `check-green` → `metal-green` → `tagged`.

- Security / patch tags on the current series: `bump-open` when the GitHub tag exists. No soak.
- Minor/major tags: `bump-open` when the tag exists and the patch train on that series has stopped (no newer patch). Optional soak only while hotfixes are still landing (example: 4.0.0 → 4.0.2 in 17 days).
- `edge` is `quattro` + nixos-unstable, maintainer only, never advertised as 1:1.
- `rc` is an official RC tag when one exists; dogfood on a VM generation, not the Latitude daily driver until it becomes stable.

**Why.** Agent time is bursty. Calendars lie. Tags and security notes do not.

---

## ADR-0006 — nixpkgs pairing

- Status: accepted (cutover date open)
- Date: 2026-09-04

**Decision.** Pair user `stable` with nixos-stable. Current pair: **26.05**. 26.05 EOL is 2026-12-31. The 26.11 cutover is a planned ROADMAP item, not an automatic follow of unstable.

**Why.** Rock-solid stability and security over bleeding edge.

**Open.** Exact 26.11 cutover trigger. New ADR when 26.11 exists.

---

## ADR-0007 — Kernel track

- Status: accepted
- Date: 2026-09-04

**Decision.** Do not block desktop stable on `linux_omarchy`. Default `boot.kernelPackages` from nixpkgs. Never `pacman -U` an Omarchy kernel onto NixOS. Re-verify the linux-ptl model if official packaging changes after 2026-09-03.

**Why.** 5420 is not the Panther Lake / XPS SKU linux-ptl targets. Kernel packaging is a separate project.

---

## ADR-0008 — Vendor rule

- Status: accepted
- Date: 2026-09-04

**Decision.** If the user can see it, it comes from `omarchy-src`. `$OMARCHY_PATH` is the store path. Patches are `--replace-fail`. One upstream rev + glue = one commit. No writable `/usr/share/omarchy`.

**Why.** Reimplementation drifts inside one release. Already proven by zicochaos and fzakaria.

---

## ADR-0009 — Script reachability rule

- Status: accepted
- Date: 2026-09-04

**Decision.** Classify every `bin/omarchy-*` at the pinned tag.

- Reached + desktop → `vendor` or `wrap`
- Reached + distro → `stub` on PATH with a parseable reason
- Unreached + distro → `drop`, ledger `na`
- New binary on bump → CI red until classified

No fake pacman. Stub message shape: `omahedron: na: <reason>` or `omahedron: stub: <reason>`.

**Why.** Menus must not 404. Dead ISO tools must not accumulate fake binaries.

---

## ADR-0010 — Plugins

- Status: accepted
- Date: 2026-09-04

**Decision.** The marketplace UI may exist if it is in the vendored shell. Any plugin that installs an Arch package or writes `/etc` as root is `na` / stub.

---

## ADR-0011 — Fish

- Status: accepted
- Date: 2026-09-04

**Decision.** Fish is the default interactive shell to match upstream. Bash remains the script runtime (`#!/bin/bash`). Users may opt out.

---

## ADR-0012 — First-run identity

- Status: accepted
- Date: 2026-09-04

**Decision.** Seed first-run from Nix options (`omarchy.fullName` / `omarchy.email`, names inherited from zicochaos unless later renamed). Fall back to NixOS user metadata. Do not require an interactive TUI for identity on NixOS.

Clarifies the earlier interview question: “who is this human” is declarative.

---

## ADR-0013 — Verification

- Status: accepted
- Date: 2026-09-04

**Decision.**

- VM (Mac minis / Studio): required **pre-gate** — eval, module import, `nix flake check`, greeter/session start if the VM can.
- Dell Latitude 5420 8 GB: **ship gate** — [checklists/metal.md](checklists/metal.md).
- Lite dogfood: all target tools installed, not all loaded. Cloud Grok stays in the cloud.
- VMSVGA / QEMU software framebuffer does not count as Quickshell verification.
- GPU passthrough from Macs is optional later, not a v1 blocker.

**Why.** Brief and zicochaos both warn that software FB lies. 8 GB is doctrine: old-hardware users are in-scope.

---

## ADR-0014 — Agent surface

- Status: accepted
- Date: 2026-09-04

**Decision.** Match Omarchy’s agent surface. Priority: Cursor and Grok must-match on v1. Cline, OpenCode, Devin, OMP are first-class and may trail one stable tag if packaging is the only blocker. Vendor presentation; wrap pacman installers.

---

## ADR-0015 — Scope phasing

- Status: accepted
- Date: 2026-09-04

**Decision.** Destination includes webapps, Voxtype, fingerprint-where-present, Windows VM helper. None of those block `omahedron-4.0.2`. See ROADMAP phases.

---

## ADR-0016 — Conflict rule

- Status: accepted
- Date: 2026-09-04

**Decision.** Domain ownership as in [AGENTS.md](AGENTS.md). Desktop vs OS collisions become ledger rows. Other collisions become ADRs. No silent overwrite of accepted ADRs.

---

## ADR-0017 — Public + private

- Status: accepted
- Date: 2026-09-04

**Decision.** One public flake. Hedronite hosts consume it. Private host data does not leak into public modules.

---

## ADR-0018 — License and credit

- Status: accepted
- Date: 2026-09-04

**Decision.** MIT. Full credit and transparency to Basecamp/Omacom Omarchy and to zicochaos/omarchy-nix. See [docs/CREDITS.md](docs/CREDITS.md).

---

## ADR-0019 — Docs-first drop

- Status: accepted
- Date: 2026-09-04

**Decision.** This working tree ships documentation, schemas, and checklists before flake code. Subagents must not invent a from-scratch flake to “get ahead.”

---

## ADR-0020 — Pin v4.0.2 implementation landed

- Status: accepted
- Date: 2026-09-04
- Deciders: human maintainer / Maintainer role

**Decision.** ADR-0019 (docs-first) is satisfied for the initial drop. Implementation is on `main`: zicochaos adopt + Omarchy tag **v4.0.2** pin (PR1), scripts.lock policy refine (PR2), Hyprland **v0.56.2** + `omarchyVersion = "4.0.2"` override (PR3), docs public scrub (PR5 @ `18261ac`). Product tag `omahedron-4.0.2` still waits Latitude metal + Nix/CI GHA.

**Why.** Flake invent is no longer the risk; premature `omahedron-4.0.2` tagging without metal/GHA is.

**Consequences.** Agents may edit `flake.nix` / `pkgs/` / modules under Maintainer GO. Do not invent a second greenfield flake. Do not tag until metal-green.

**Supersedes in part:** ADR-0019’s “no flake code yet” clause — docs-first for the *drop* remains historical; the tree now has code.

---

## ADR-0021 — allowUnfree default (ADOPT)

- Status: accepted
- Date: 2026-09-04
- Deciders: human maintainer (Evan law via Maintainer)

**Decision.** `allowUnfree` **default on** is Omahedron / Hedronite posture. We are OSS users and contributors, not FOSS fanatics. Align with nixarchy’s Install-menu-friendly default. Do not treat “keep allowUnfree explicit / off by default” as a virtue or an Avoid in competitive notes.

**Why.** Omarchy’s selectable apps are largely unfree; a default-off policy makes the Install loop die on license errors and misrepresents how the desktop is used.

**Consequences.** Module / catalog unfree whitelist stays; consumers who want a free-only machine override explicitly. Competitive teardown and SecOps notes must not re-litigate this as mesh purity.

---

## ADR-0022 — Public scrub; fleet runbooks outside git

- Status: accepted
- Date: 2026-09-04

**Decision.** Public tree must not carry named fleet operators, `docs/FLEET.md`, or `docs/WORKSPACE.md`. AGENTS.md uses role titles only (Maintainer, Nix/CI, SecOps, UX/metal, Schema, Publishing). Private copies live in the vault under `ideas/foundry/omahedron/internal/`. `.gitignore` blocks `docs/FLEET.md`, `docs/WORKSPACE.md`, `AGENTS.hedronite.md`, `.hedronite/`, `PRIVATE.md`. Flake URL examples use `github:VirtualMachinist/Omahedron`.

**Why.** Public collaboration without leaking internal fleet structure. PR5.

**Consequences.** Vault internal/ is SoT for fleet cards; repo AGENTS.md is the public operating manual. Do not re-commit FLEET/WORKSPACE.

---

## ADR-0023 — NetworkManager before graphical session

- Status: accepted
- Date: 2026-09-04
- Landed: Omahedron PR #7 merge `4437f39`

**Decision.** Order `NetworkManager.service` **Before=** `display-manager.service` (no Requires=) so Quickshell binds NM’s D-Bus name after the bus is up. Upstream QML fix is separate (omacom/omarchy#9923). Diff source: open [zicochaos/omarchy-nix#4](https://github.com/zicochaos/omarchy-nix/pull/4) (VirtualMachinist); **absent** on Omahedron `main` as of 2026-09-04 recon — land via small follow-up PR.

**Why.** quickshell 0.3.0 has no NameOwnerChanged recovery (basecamp/omarchy#7324); race paints NOT CONNECTED while the link is up.

**Consequences.** Until merged: known first-boot / race gap. Omahedron PR open: https://github.com/VirtualMachinist/Omahedron/pull/7 @ `e33aa54` (Marci PASS). After merge: mark accepted and cite that PR. Do not vendor-patch QML in `pkgs/` for this.
