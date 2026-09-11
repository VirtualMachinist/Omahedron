# Rebase / overlay plan (G2)

Glue upstream: [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix) `main` @ `c9f235637585189c71b3e8c53fce7f77fa5c9a87` (public snapshot of `673a57f2`).

Omahedron branch: `feat/compete` (G0 @ `4374d86`, G1 @ `a39d27a`). **This document is the G2 deliverable.** It does **not** bump `omarchy-src` (G3).

## Pin snapshot (2026-09-11)

| Input | Omahedron (now) | zicochaos `main` | G3 target (stable tag, not quattro HEAD) |
|---|---|---|---|
| `omarchy-src` ref | `github:basecamp/omarchy/v4.0.2` | `github:basecamp/omarchy/quattro` | `github:basecamp/omarchy/v4.0.3` |
| Locked rev | `346e69e1cec6c4e8924531874af6ba010a1bc99e` | `5b91db503c904bbfc5f34bdaaa9c708814958f3d` | `0534987009061cbe2dacdde4ad564092ab698d12` |
| Effective desktop | v4.0.2 security wave | v4.0.3-equivalent glue on quattro | Official stable v4.0.3 (asdcontrol security credit + v4.0.3 migrations) |

Official delta v4.0.2 → v4.0.3 is one release commit (asdcontrol security report credit). zicochaos tracks **quattro**, not the stable tag; treat their tree as **glue to cherry-pick**, not as the release channel (ADR-0005, AGENTS.md, COMPETE §5).

## Strategy

1. **Overlay, not merge.** Keep Omahedron's vendor derivation shape (`pkgs/omarchy.nix` + manifests + `--replace-fail`). Port zicochaos hunks as targeted cherry-picks or manual overlays — never a from-scratch rewrite (G2b).
2. **One upstream rev + glue = one commit** (bump checklist). Ledger rows (`schema/scripts.lock.json`, `schema/packages.map.json`, migration/etc/runtime manifests) change in the **same commit** as the pin and vendor patches.
3. **Preserve Omahedron-only wins** from G0–G1 and compete work (below). Reject zicochaos regressions even when their tree is newer.

## Omahedron-only — do not drop at G3

| Domain | Keep | Reject from zicochaos |
|---|---|---|
| Locator (G0) | `$OMARCHY_NIX_FLAKE` → `/etc/nixos` only; scavenger paths fail | `~/omarchy-nix/`, `~/Projects/omarchy-nix/` resolver fallbacks |
| Profiles (G1) | `omarchy.profile` (`desktop` default) + `omarchy.unfree.enable` (default false); workstation-only Docker/zram/sysctl; Obsidian gated on unfree | Full upstream kitchen-sink in core `runtimeDeps`; global Obsidian allowUnfree |
| Release | Pin **stable tags**, not `quattro` HEAD | `flake.nix` `ref = "quattro"` |
| Compete checks | `omarchy-flake-resolver`, `omarchy-profile-desktop`, etc-parity split by profile | — |
| Module ordering | `NetworkManager.before = display-manager` (Omahedron port) | — |
| Fish | Opt-in `programs.fish`; no `users.defaultUserShell` override | zico sets default shell fleet-wide |
| Migrations | `1788102906.sh` = **adapter** (XCompose user half + Nix udev adapter) | zico classifies as **skip** (drops user repair) |
| Stub honesty | `omahedron: stub:` banners on declarative Nix verbs where applicable | zico drops some stub banners |

## Diff summary (Omahedron vs zicochaos `main`)

Compared at G2 baseline (`a39d27a`):

| Artifact | Lines (Omahedron / zico) | Notes |
|---|---|---|
| `pkgs/omarchy.nix` | 2085 / 2136 | Menu rewires, remove-script patches, catalog probes, locator |
| `modules/nixos/default.nix` | profile split vs full parity | qt6, nvi, cups-pk-helper, kitty etc, docker/zram, sudoers, fish |
| `config.nix` | profiles + unfree | zico lacks G1 options |
| `pkgs/omarchy-migrations.nix` | v4.0.2 wave + adapter 1788102906 | zico adds v4.0.1/4.0.3 rows; different 1788102906 class |
| `pkgs/omarchy-etc-manifest.nix` | partial v4.0.2 CUPS notes | zico adds mise/asdcontrol/CUPS/sysusers rows |
| `pkgs/omarchy-runtime-manifest.nix` | declarative-note stubs | zico adds browser-policy stub ordering notes |

## Cherry-pick / overlay queue (G3 execution)

Execute in order after `nix flake lock --update-input omarchy-src` to **v4.0.3**. Follow [checklists/bump.md](../checklists/bump.md) and [docs/UPSTREAM.md](UPSTREAM.md).

### A — `modules/nixos/default.nix` (take glue, keep G1)

| Item | Source (zico) | Action |
|---|---|---|
| `qt6.qtimageformats` | runtimeDeps | **Take** — backs migration `1787133200` (webp theme backgrounds) |
| `qt6.qtmultimedia` | runtimeDeps | **Take** — backs migration `1786609204` (video wallpaper) |
| `nvi` | runtimeDeps | **Take** — backs migration `1788596255` (`vi` command) |
| `cups-pk-helper` | runtimeDeps | **Take** — CUPS hardening parity |
| `environment.etc."xdg/kitty/kitty.conf"` | v4.0.3 etc vendoring | **Take** — upstream moved stock kitty defaults to system XDG |
| CUPS browsed comments | printing block | **Take** comment refresh; keep `browsed.enable = false` |
| Remove `omarchy-asdcontrol` NOPASSWD | sudoers (v4.0.1 security) | **Take** — match upstream password prompt |
| Tighten `timedatectl set-timezone` regex | sudoers (v4.0.2) | **Take** |
| `omarchy-tailscale-receive` gated on `services.tailscale.enable` | user units | **Take** |
| `managedPackages` nested attr paths (`attrByPath`) | feature resolver | **Take** — fixes `kdePackages.*` catalog paths |
| Docker + zram + full sysctl block in core | zico default | **Reject** — keep G1 workstation profile gate |
| Obsidian/libreoffice/kdenlive/mise/lazydocker in core `runtimeDeps` | zico default | **Reject** — keep workstation profile + unfree gate |
| Global Obsidian allowUnfree | zico B0 block | **Reject** — keep `omarchy.unfree.enable` |
| `users.defaultUserShell = fish` | fish block | **Reject** — keep opt-in fish |

### B — `pkgs/omarchy.nix` (surgical overlays — no rewrite)

| Item | Action |
|---|---|
| `omarchy-launch-webapp` desktop-dir patch (with browser patch) | **Take** after pin bump re-run `--replace-fail` |
| `omarchy-remove-ai-ollama` systemctl/`/var/lib` notes | **Take** |
| Drop stale `omarchy-remove-dev-env` pacman `--replace-fail` (post-v4.0.2 upstream uses pkg-drop) | **Take** — verify against new `bin/` |
| `omarchy-theme-set-browser-policy` stub script block | **Take** (unreachable; module owns policy dirs) |
| Menu: `install.ai.openclaw` → `omarchy-nix-add install.ai.openclaw` | **Take** + add catalog entry + `insecureNames` if upstream ships insecure deps |
| Menu: `disabled:` guard literals for NordVPN/ONCE removal | **Take** — upstream v4.0.0+ uses `disabled:` not `when:` |
| Default-agent / mise-dir menu rewires (post-v4.0.2 upstream shape) | **Take** hunks; re-validate against v4.0.3 `omarchy-menu.jsonc` |
| Runtime manifest removals: `install.ai.hermes`, `perplexity`, `t3-code` | **Take** if present at v4.0.3 pin |
| Gemini menu line / antigravity catalog notes | **Take** upstream menu shape; keep Nix catalog policy |
| Scavenger flake resolver paths | **Reject** — keep G0 resolver |
| Drop `omahedron: stub:` on Nix verb wrappers | **Reject** — keep stub banners for G8 |

### C — Manifests + ledgers (same commit as pin)

| File | Action |
|---|---|
| `pkgs/omarchy-migrations.nix` | Merge zico v4.0.1/4.0.3 classifications **except** keep `1788102906.sh` = `adapter`; add `1786609204`, `1788596255`, `1787843905`, `1788595060` as zico; reclassify `1787133200`/`1788596255`/`1786609204` skip comments to cite module deps |
| `pkgs/omarchy-etc-manifest.nix` | Merge zico CUPS/mise/asdcontrol/sudoers rows; keep Omahedron `native`/`na` honesty |
| `pkgs/omarchy-runtime-manifest.nix` | Merge zico browser-policy + sudoless-docker note wording |
| `schema/scripts.lock.json` | Re-scan `bin/` at v4.0.3; classify every new/changed `omarchy-*` |
| `schema/packages.map.json` | Map any new install catalog ids (incl. `openclaw` if shipped) |
| `flake.nix` checks | Extend migration/etc parity probes for new vendored paths |

### D — Docs / options (same PR stack, may follow pin commit)

| File | Action |
|---|---|
| `docs/UPSTREAM.md` | Update “latest stable” to v4.0.3 after G3 |
| `docs/options.md` | Document any new module options introduced by overlays |
| `docs/COMPAT.md` | Notes for asdcontrol sudo change, kitty etc layering, openclaw insecure permit if any |

## zicochaos commits to use as reference

Their public repo exposes a single snapshot commit (`c9f2356`). Use **file diffs against that tree**, not a blind `git merge`. Internal history (from snapshot message): glue evolved on quattro through v4.0.3-equivalent `5b91db5`.

Equivalent manual cherry-pick themes (no SHA list required — diff is the source):

1. v4.0.3 runtime deps (qt6-multimedia, nvi, cups-pk-helper, kitty etc)
2. v4.0.1 security sudoers (drop asdcontrol NOPASSWD)
3. v4.0.2 CUPS / docker-group / browser-policy migration glue
4. Menu/catalog rewires for openclaw, default-agent, ollama remove, disabled-guard shape
5. Manifest classification expansion for v4.0.1–4.0.3 migrations

## G3 gate checklist (do not start until this plan merges)

- [ ] `nix flake lock --update-input omarchy-src` → **v4.0.3 tag** (`0534987…`), not quattro
- [ ] `nix flake check` — fix or drop every failed `--replace-fail`; COMPAT note if dropped
- [ ] `schema/scripts.lock.json` + `schema/packages.map.json` + manifests updated same commit
- [ ] G1 profile checks still green (`omarchy-profile-desktop`, etc-parity workstation path)
- [ ] G0 locator check still green (scavenger paths fail)
- [ ] VM pre-gate + Latitude metal per COMPETE §4
- [ ] Bump record from [templates/bump-record.md](../templates/bump-record.md)

## Risk register

| Risk | Mitigation |
|---|---|
| `--replace-fail` drift on v4.0.3 `bin/` | Run check immediately after lock; cite upstream paths in commit |
| New `omarchy-*` binary unclassified | CI `omarchy-scripts-lock` fails closed — classify before merge |
| openclaw / insecure AI deps | Catalog `insecureNames` scoped permit; document in COMPAT |
| Accidentally merging zico scavenger locators | G0 flake check + code review against this table |
| Silent fork via full `pkgs/omarchy.nix` rewrite | Forbidden (G2b); overlay hunks only |

## References

- [docs/UPSTREAM.md](UPSTREAM.md) — bump procedure
- [checklists/bump.md](../checklists/bump.md) — ordered bump steps
- [docs/COMPETE.md](COMPETE.md) §5 — compete gates
- zicochaos tree: `github:zicochaos/omarchy-nix/c9f235637585189c71b3e8c53fce7f77fa5c9a87`
- Official tag: `github:basecamp/omarchy/v4.0.3` @ `0534987009061cbe2dacdde4ad564092ab698d12`
