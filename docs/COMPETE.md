# Omahedron — Beat Every Nix Omarchy Port

Handoff for agents. Product goal: Omahedron is the best Omarchy port on NixOS. Not the best-documented fork. Not the prettiest brand kit. The flake a competent person actually chooses over zicochaos/omarchy-nix, nixarchy, omanix, henrysipp/omarchy-nix, and omanixy.

Read this before changing user-visible desktop behavior, module defaults, pins, or README claims.

> **As landed 2026-09-11 (ADR-0024).** Verified against `github:VirtualMachinist/Omahedron` `main` @ `08e2f1d`:
>
> - Git tag `omahedron-4.0.2` exists (annotated; Latitude metal-cleared). There is no GitHub Release.
> - Public README still tells people to track `main` until metal sign-off.
> - `schema/scorecard.json` is not in tree yet.
> - Kitchen-sink defaults (Docker, Steam, zram 100%, swappiness 150) and scavenger flake paths (`~/omarchy-nix`, `~/Projects/omarchy-nix`) are still live on `omarchy.enable`.
>
> Landscape §1 is the 2026-09 competitive snapshot. Live git wins for inventory. This file wins for the *bar* (what “best” means, module shape, release identity). Do not call this the best port until §4.5 allows.

## 0. How to use this file

| If you are doing | This document wins on |
|---|---|
| What we ship / what “best” means | §2 Spec |
| Machine-readable contracts (pins, profiles, ledgers, stubs, scorecards) | §3 Schema |
| Whether a change is allowed to merge or a pin is allowed to tag | §4 Rubric |
| What the other ports already do | §1 Landscape |
| What we refuse to spend time on | §2.6 Non-goals |

Conflicts: pinned `omarchy-src` owns pixels. NixOS owns boot, store, privileges. This file owns release identity, module shape, and competitive bar. Do not invent a “README always wins” hammer.

## 1. Landscape (facts, not vibes)

All of these exist. Do not rediscover them.

| Port | Repo | Approach | Status (2026-09) | Why people pick it |
|---|---|---|---|---|
| zicochaos/omarchy-nix | github:zicochaos/omarchy-nix | Vendor upstream tree, do not rewrite | ~32★, tracks quattro HEAD, Omarchy v4.0.3, UX VM suite | Closest to real Quattro on Nix today |
| nixarchy | github:olafkfreund/nixarchy | Vendor 4.x; Nix-facing CLI (`nixarchy search/pkg/apply`) | Active vendor port | Clear verbs for the Nix layer |
| T00fy/omanix | github:T00fy/omanix | Nix-native reimplementation | ~92★ | Declarative rice; accepts no live theme swap |
| henrysipp/omarchy-nix | github:henrysipp/omarchy-nix | Early reimplementation / launchpad | ~797★, author moved back to Arch, not actively maintained | Mindshare and Google result for “omarchy nix” |
| omanixy | github:atqamz/omanixy | Narrow presentation/OS boundary | ~16★ | Thin integration layer |
| Omahedron | github:VirtualMachinist/Omahedron | Fork of zicochaos + tag pins + ledgers + metal gate | 0★, created 2026-09-04, pin v4.0.2, git tag `omahedron-4.0.2` @ `08e2f1d` (no GitHub Release; README still hedges) | Trailing-stable on paper; Hedronite fleet flake |

Omahedron’s current delta vs zicochaos: tag-pin policy, `schema/scripts.lock.json` + `packages.map.json`, COMPAT ledger, ADRs, Latitude 5420 metal checklist, brand. That is not enough. zicochaos is already newer upstream. henrysipp already owns the search term. nixarchy already owns the Nix CLI idea. omanix already owns Nix-purist philosophy.

We do not beat them by looking more like Arch Omarchy. We beat them by being the port that is pinned, thin-by-default, honest about gaps, fast to rebuild, and better at the Nix-facing verbs (update / install / theme / rollback).

## 2. Spec

### 2.1 One sentence

Omahedron ships a Nix flake that makes a NixOS machine look and drive like official Omarchy stable (trailing their release tags), with every OS-layer gap written down, a thin desktop profile, and Nix verbs that do not feel like a broken pacman.

### 2.2 Success metric

A user who already runs NixOS, or who left Arch Omarchy because of `pacman -Syu` pace, chooses `github:VirtualMachinist/Omahedron` over the table in §1.

“Chooses” is measured by all of:

1. Sit-down parity on hardware no more generous than the Hedronite Latitude 5420 (8 GB, lite-loaded): same shell, menus, theme engine, bindings, first-class agent surface as Arch Omarchy `vX.Y.Z`, with documented OS-layer gaps.
2. Named pin. `omahedron-X.Y.Z` exists, matches Omarchy `vX.Y.Z`, and is what README tells people to follow.
3. First rebuild is survivable. Hyprland/Mesa come from a documented binary cache. Install doc does not assume you know where zicochaos used to put its flake.
4. Module is not a stealth laptop image. `omarchy.enable` can mean desktop-only. Workstation extras are a profile.
5. Scorecard in §4.3 is win or tie-break-win against every row in §1 on the published rubric. Ties against zicochaos on pixels are expected; losses on freshness, thinness, or update UX are disqualifying.

Cloud-hosted agents do not have to run on the laptop. Pixel claims are invalid if they were only proven as “Hyprland socket exists in QEMU.”

### 2.3 Product shape

Omahedron is not a distro and not a rewrite.

```
basecamp/omarchy @ tag vX.Y.Z     → pixels, scripts, themes, Quickshell
NixOS 26.05 + systemd-boot        → boot, generations, privileges, store
Omahedron flake                   → pin, profiles, ledgers, stubs, Nix verbs
```

Rocky/Alma : CentOS  ::  Omahedron : Omarchy desktop.

Keep: trailing blessed tags, independent maintenance, compatibility as a ledger, no claim to be Basecamp/Omacom, security patches immediately.

Drop: same installer, same kernel package, official support, marketplace entries that assume pacman or root writes to `/etc`.

### 2.4 In scope

- One Quickshell process and plugins from pinned `omarchy-src`
- Hyprland Lua bootstrap (≥ version required by that pin) + user overrides in `~/.config`
- Theme engine (TOML + templates) with live swap (this is a vendor-port invariant; do not regress to omanix build-time themes)
- `omarchy-*` commands that are not package-manager or boot specific
- Default bindings
- First-run provisioning, Nix-seeded identity
- NixOS module + Home Manager module under existing `omarchy.*` namespace (do not rename in v1)
- Profiles: `desktop` | `workstation` | `unfree` (see schema)
- Nix-native update / install / remove that write flake state and rebuild
- Script + package ledgers with CI fail-closed on drift
- Metal gate on named hardware before a stable tag
- Agent-facing contract: parseable stubs, vault-relative tools if Lapis is present, no fake pacman

### 2.5 Out of scope (v1)

- ISO / installer competing with official NixOS install
- `linux_omarchy` / official Omarchy kernel package as a ship gate
- Omacom patronage features
- Windows, macOS, or non-NixOS
- Rewriting Quickshell/Hyprland config in Nix (that is omanix’s product)
- Tracking `quattro` HEAD on the user-facing stable channel
- Using the reserved brand Omarchanite in this repo
- Claiming affiliation with Omarchy, Omacom, 37signals, or DHH

### 2.6 Non-goals (do not spend the budget here)

- More logos, motion posters, or sibling brand names
- Winning henrysipp on GitHub stars this quarter
- Racing zicochaos to `quattro` HEAD
- Inflating “431 commands classified” as a README headline without a tagged pin people are told to follow
- Kitchen-sink defaults that copy a private fleet image into every consumer
- Process for its own sake (ADRs that do not change a rebuild)

### 2.7 Competitive strategy (what “outcompete” means)

Beat each port on the axis they are weak, without giving up vendor-port pixels.

| Competitor | They win today on | We beat them by |
|---|---|---|
| zicochaos/omarchy-nix | Freshness, same vendor architecture, UX tests | Named tags, thinner default, better flake locator, published metal-signed gap list, rebase/overlay so we do not lag 4.0.2 vs 4.0.3 |
| nixarchy | Named Nix CLI | Equal-or-better verbs (update, pkg add/remove, search, apply) without forcing a second product name onto every command; keep `omarchy` for pixels, one obvious Nix entrypoint |
| omanix | Nix-native purity, stars | Live theme swap + real upstream Quickshell; optional thin profile so purists are not force-fed Steam/Docker |
| henrysipp/omarchy-nix | Search mindshare, abandoned | Being the maintained vendor port; README must answer “is this henrysipp?” in the first screen |
| omanixy | Narrow boundary | Ship a complete sit-down desktop, not only a boundary theory |

Hard rule: treat zicochaos as glue upstream. Rebase or overlay. Do not silently fork `pkgs/omarchy.nix` until the files are unmergeable. Packaging fixes go back upstream when they are not Omahedron-specific.

### 2.8 Module contract

`omarchy.enable = true` with default profile `desktop` must give:

- Vendored tree on PATH as `$OMARCHY_PATH`
- Hyprland + UWSM session
- Quickshell bar/launcher/menus/lock
- Live theme swap
- SDDM + Omarchy theme (opt-out allowed)
- PipeWire, NetworkManager, Bluetooth
- Stubs that print `omahedron: stub:` or `omahedron: na:` and exit 0/2 as documented — never a pacman impersonator

`omarchy.enable = true` must **not** by default enable: Docker, Steam, Obsidian, Kdenlive, LibreOffice, mise-as-system-dev, zram at 100% of RAM, or `allowUnfree = true` for the whole system.

Those belong on `profile = "workstation"` and/or `omarchy.unfree.enable = true`.

Unfree remains first-class and easy (ADR-0021 posture: we are not FOSS-purist). It is no longer a silent global default on the desktop profile (ADR-0024).

### 2.9 Update / install contract

Update and package menus are how vendor ports die.

Required behavior:

1. Flake discovery order is only:
   - `$OMARCHY_NIX_FLAKE`
   - `/etc/nixos` if it contains `nixosConfigurations.<hostname>`
   - Fail with a message that tells the user the exact env var to set
2. Delete scavenger paths (`~/omarchy-nix/`, `~/Projects/omarchy-nix/`). Those are zicochaos fork residue.
3. `omarchy update` (or the Nix entrypoint) prints: current Omahedron pin, current `omarchy-src` tag, newest known Omarchy stable tag, channel state, whether this bump is security-fast-path or soak.
4. Install/Remove writes declarative state (JSON or Nix fragment) and runs rebuild. Rollback is a previous NixOS generation, not “undo pacman.”
5. If a menu action is a stub, the UI shows the stub reason. No dead menu entries.

### 2.10 Release contract (Omachron)

Channels match official names: `stable` (default), `rc`, `edge`.

State machine: `watching` → `bump-open` → `check-green` → `metal-green` → `tagged`.

| Event | Action |
|---|---|
| Omarchy security/patch tag | `bump-open` immediately; no soak |
| Omarchy minor/major tag | soak until patch train settles; then metal gate |
| edge | maintainer-only; `quattro` + nixos-unstable |
| rc | VM dogfood, not Latitude until stable |

`stable` pairs with nixos-stable (26.05 until the ROADMAP cutover to 26.11). Cutover is a planned bump, not automatic.

No public claim of `omahedron-X.Y.Z` as *the* follow target until: ledger pin == `flake.lock` ref == upstream tag, CI green, metal checklist signed, README tells people to follow that tag.

### 2.11 Agent contract

Agents are first-class consumers of the port, not just of Lapis.

- Every stub is parseable (`omahedron: <class>: <reason>`).
- Ledger classes are the only allowed explanations for “this omarchy command does nothing.”
- Prefer search/tooling over grepping the vendored tree.
- Do not rewrite HAL/frontmatter or user hypr Lua by guesswork.
- If Lapis is installed, notes stay files; Omahedron does not become a second vault.

## 3. Schema

Normative types. JSON below is the contract. Existing files (`schema/scripts.lock.json`, `schema/packages.map.json`, `docs/COMPAT.md`) must be migrated toward these shapes; do not keep a second unofficial enum.

### 3.1 Enums

```
Channel        = "stable" | "rc" | "edge"
ChannelState   = "watching" | "bump-open" | "check-green" | "metal-green" | "tagged"
Profile        = "desktop" | "workstation"
ScriptClass    = "vendor" | "wrap" | "stub" | "host" | "na" | "drop"
PackageStatus  = "nixpkgs" | "local" | "host" | "unfree" | "missing" | "na"
Verdict        = "win" | "tie" | "loss" | "n/a"
Gate           = "fail" | "pass"
```

- `vendor` = upstream script shipped with path/shebang adaptation only.
- `wrap` = NixOS-native replacement behind the same command name.
- `stub` = reached + distro-specific; prints reason; no fake work.
- `host` = NixOS owns it (bootloader, generations, NetworkManager).
- `na` = not applicable on NixOS (pacman).
- `drop` = unreached + distro; must not appear on PATH or in menus.

### 3.2 Pin record

`schema/pin.json` (one current pin; history in changelog / bump records).

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "omahedron.pin",
  "type": "object",
  "required": [
    "omahedron_version",
    "omarchy_tag",
    "omarchy_rev",
    "hyprland_tag",
    "nixpkgs_branch",
    "channel",
    "state"
  ],
  "properties": {
    "omahedron_version": { "type": "string", "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$" },
    "omarchy_tag": { "type": "string", "pattern": "^v[0-9]+\\.[0-9]+\\.[0-9]+" },
    "omarchy_rev": { "type": "string", "minLength": 40, "maxLength": 40 },
    "hyprland_tag": { "type": "string" },
    "nixpkgs_branch": { "type": "string" },
    "home_manager_branch": { "type": "string" },
    "channel": { "enum": ["stable", "rc", "edge"] },
    "state": {
      "enum": ["watching", "bump-open", "check-green", "metal-green", "tagged"]
    },
    "security_fast_path": { "type": "boolean" },
    "flake_lock_agrees": { "type": "boolean" },
    "gaps_doc": { "type": "string", "description": "path to per-pin COMPAT slice" }
  }
}
```

Invariant: `omarchy_tag` and `omarchy_rev` must equal `flake.lock` input `omarchy-src`. CI fails otherwise.

### 3.3 Script ledger row

Extends `schema/scripts.lock.json`.

```json
{
  "name": "omarchy-pkg-add",
  "class": "stub",
  "since_pin": "v4.0.2",
  "reason": "nixos-declarative",
  "path_in_src": "bin/omarchy-pkg-add",
  "replacement": "omarchy-nix-add",
  "menu_visible": true,
  "parseable_banner": "omahedron: stub: nixos-declarative",
  "agent_hint": "Tell the user to add the package to their flake and rebuild; do not invoke pacman."
}
```

Required fields: `name`, `class`, `since_pin`.
If `class` = `stub`|`na`, `reason` and `parseable_banner` are required.
If `class` = `wrap`, `replacement` is required.
CI: every `bin/omarchy-*` at the pinned tag is in the ledger. Unclassified = red. Packaged stub body must contain the banner.

### 3.4 Package map row

```json
{
  "upstream_name": "obsidian",
  "status": "unfree",
  "attr": "obsidian",
  "source": "nixpkgs",
  "profile": "workstation",
  "unfree": true,
  "feature_option": "programs.obsidian or packages list",
  "notes": "Not in desktop profile."
}
```

Required: `upstream_name`, `status`. Unfree packages default off unless `profile=workstation` + `omarchy.unfree.enable`.

### 3.5 Module profiles

```nix
omarchy.enable = true;                 # required opt-in
omarchy.profile = "desktop";           # default
omarchy.unfree.enable = false;         # default
omarchy.fish.enable = true;            # default on desktop; opt-out allowed
omarchy.sddm.enable = true;
omarchy.plymouth.enable = true;
omarchy.managedPackagesFile = null;    # JSON from install menu
```

| Profile | Allowed to pull in |
|---|---|
| desktop | Compositor, Quickshell, themes, bindings, portals, audio, BT, NM, fonts, terminal, editor launcher, stubs, fish vendor profile |
| workstation | desktop + Docker/dev CLIs/heavy GUI/creative suite as mapped |
| unfree.enable | Steam, Obsidian, and other unfree rows; never implied by desktop |

Kitchen-sink sysctls (zram = 100%, swappiness = 150, Docker-on-by-default) are workstation or explicit options. They are not silent `mkDefault` on desktop.

### 3.6 Stub banner

Format: `omahedron: <class>: <reason>`

Examples:

```
omahedron: stub: nixos-declarative
omahedron: na: pacman
omahedron: stub: host-bootloader
omahedron: wrap: flake-rebuild
```

Regex for agents and CI:

```
^omahedron: (stub|na|wrap|host): [a-z0-9-]+$
```

First line of stdout. Then a human sentence. Exit 0 for stub/na that are successfully declined; exit 2 only when the lattice/host is actually down.

### 3.7 Flake locator

```json
{
  "order": [
    { "type": "env", "name": "OMARCHY_NIX_FLAKE" },
    { "type": "path", "path": "/etc/nixos", "must_contain_hostname": true }
  ],
  "forbidden": [
    "~/omarchy-nix",
    "~/Projects/omarchy-nix",
    "~/Omahedron"
  ]
}
```

### 3.8 Competitor scorecard row

`schema/scorecard.json` — produced by agents after a bump or quarterly, checked in.

```json
{
  "as_of": "2026-09-11",
  "our_pin": "4.0.2",
  "rows": [
    {
      "competitor": "zicochaos/omarchy-nix",
      "axes": {
        "pixel_parity": "tie",
        "pin_freshness": "loss",
        "thin_default": "loss",
        "nix_verbs": "tie",
        "honesty_of_gaps": "win",
        "rebuild_time": "n/a",
        "tests": "loss",
        "docs_first_hour": "tie"
      },
      "verdict": "loss",
      "notes": "They are on v4.0.3 HEAD. We have a git tag but no public Release, and we still trail their pin."
    }
  ]
}
```

Any `verdict: loss` against zicochaos or nixarchy on `pin_freshness`, `thin_default`, or `nix_verbs` blocks calling ourselves “the best port” in README.

### 3.9 Rubric result

```json
{
  "candidate": "omahedron-4.0.3",
  "gates": {
    "pin_locked": "pass",
    "ledgers_closed": "pass",
    "profiles_split": "pass",
    "locator_clean": "pass",
    "ci_green": "pass",
    "vm_pre_gate": "pass",
    "metal_green": "fail"
  },
  "ship": false,
  "readme_may_say_best": false
}
```

`ship` requires every gate pass. `readme_may_say_best` requires ship plus scorecard with no disqualifying loss per §4.3.

## 4. Rubric

Score work and releases. Do not argue taste when a row is red.

### 4.1 Merge gates (every PR)

| ID | Gate | Pass if | Fail if |
|---|---|---|---|
| G1 | Pin integrity | scripts.lock pin + rev == flake.lock omarchy-src | Drift, floating quattro on stable |
| G2 | Ledger closed | Every upstream `bin/omarchy-*` classified; stubs match banners | New binary unclassified; stub body disagrees with class |
| G3 | Package map | Every upstream package name mapped; local attrs evaluate | Missing / unevaluated attr claimed as shipped |
| G4 | Profile split | desktop eval does not enable Docker/Steam/Obsidian/unfree-global | Kitchen sink leaks into default |
| G5 | Locator | Only env + `/etc/nixos`; forbidden paths absent from scripts and docs | `~/omarchy-nix` still referenced as a supported locator |
| G6 | Options documented | Every `omarchy.*` option has a heading in `docs/options.md` | Drift |
| G7 | Formatter / eval | `nix fmt` + relevant `nix flake check` subset green | Red CI |
| G8 | No fake pacman | No script invokes pacman/yay or writes `/usr/share/omarchy` | Impersonation |
| G9 | Credit | zicochaos + basecamp named where glue/pixels are theirs | Rebrand-without-attribution |
| G10 | Claim discipline | README does not say “best” / “same pixels” unless §4.3 allows | Marketing ahead of gates |

A PR that only adds brand assets cannot merge if G4–G5 are still red on main. Credit mentions of `zicochaos/omarchy-nix` as *upstream glue* are not locator residue.

### 4.2 Tag gates (`omahedron-X.Y.Z`)

All merge gates, plus:

| ID | Gate | Pass if |
|---|---|---|
| T1 | Tag match | Flake tag `omahedron-X.Y.Z` corresponds to Omarchy `vX.Y.Z` (patch alignment documented if we skip) |
| T2 | CI full | Light + system jobs, including desktop/ux/fish VM tests |
| T3 | VM pre-gate | Hyprland socket, Quickshell registered, portal up; UX suite covers Super+Enter, theme set, menu open |
| T4 | Metal-green | `checklists/metal.md` signed on Latitude 5420 8 GB (or recorded equivalent): login, bar, live theme, lock, terminal, editor, update dry-run, stub sample |
| T5 | Per-pin COMPAT | Gap list for this tag published; stubs in menus explained |
| T6 | Cache | Install doc has a working substituter for Hyprland/Mesa; first-build path tested |
| T7 | Scorecard | `schema/scorecard.json` updated for this pin |

No tag if T4 is fail. Process-level QEMU is T3 only.

### 4.3 Competitive scorecard (axes)

Score us vs each competitor. Use only `win` / `tie` / `loss` / `n/a`.

| Axis | Weight | win | loss |
|---|---|---|---|
| pixel_parity | 20 | Same Quickshell + live themes + bindings as Arch tag | Reimplementation drift (omanix-style) or broken bar |
| pin_freshness | 15 | stable pin is current Omarchy stable or one security-fast-path behind with a dated plan | Stable pin older than zicochaos and older than current Omarchy stable with no followable public tag |
| thin_default | 15 | desktop profile is sit-down usable without unfree/Docker/creative suite | `enable = true` is a fleet image |
| nix_verbs | 15 | Update/install/search/apply work with documented locator; stubs parseable | Flake scavenger hunt; dead menus; two CLIs with no map |
| honesty_of_gaps | 10 | COMPAT + banners match reality | README implies pacman/ISO/Omacom/kernel parity |
| rebuild_time | 10 | Documented cache; clean rebuild measured on Latitude-class box | Multi-hour uncached Hyprland as the only path |
| tests | 10 | Ledger CI + VM UX + metal record | Eval-only or “socket exists” as sole proof |
| docs_first_hour | 5 | Install from NixOS in one sitting; henrysipp disambiguated | Fork residue paths, missing options doc |

Disqualifiers (cannot claim “best port”):

- `pin_freshness = loss` vs zicochaos
- `thin_default = loss` vs any vendor port
- `nix_verbs = loss` vs nixarchy
- `pixel_parity = loss` vs zicochaos (means we broke vendor-port identity)
- No tagged release on stable that README tells people to follow

Weighted total is a diagnostic, not a vanity number. Agents report axis verdicts, not a single 100-point score, unless asked.

### 4.4 Quality rubric for code changes

Use on `pkgs/omarchy.nix`, modules, wraps.

| Grade | Meaning | Allowed on stable? |
|---|---|---|
| A | Vendor-minimal patch; `--replace-fail`; ledger updated; profile-aware | Yes |
| B | Wrap with Nix semantics, same command name, tests | Yes |
| C | New option with docs and default that preserves thin desktop | Yes |
| D | Behavior change without ledger/COMPAT | No |
| F | Rewrite of Quickshell/Hyprland in Nix; silent unfree; leftover `~/omarchy-nix` as a supported locator | No |

### 4.5 Definition of “best” (ship phrase)

Agents may put this sentence in README only when `schema/scorecard.json` + tag gates allow:

> Omahedron is the trailing-stable vendor port of Omarchy on NixOS: pinned to official tags, thin desktop by default, Nix update/install that rollback with generations, and a public ledger of every command that cannot exist on Nix.

Until then the honest sentence is:

> Unofficial NixOS vendor port of Omarchy v4.0.2, forked from zicochaos/omarchy-nix. Git tag `omahedron-4.0.2` exists; do not pick this over zicochaos if you want current Quattro HEAD, and do not say “best port” until the scorecard and tag gates allow.

## 5. Work queue (agents)

Execute in order. Do not start 5 before 1 is green.

1. **Locator purge** — remove `~/omarchy-nix` and friends from scripts, docs, comments as *supported* discovery. `$OMARCHY_NIX_FLAKE` + `/etc/nixos` only. Credit mentions of the zicochaos repo stay.
2. **Profiles** — implement `desktop` vs `workstation` vs `unfree.enable`. Move Docker/Steam/Obsidian/zram-100/swappiness-150 off default.
3. **Rebase/overlay plan** — diff `pkgs/omarchy.nix` and modules against zicochaos `main`. List cherry-picks needed to reach Omarchy v4.0.3 without dropping ledgers.
4. **Pin bump to current stable** — or document why 4.0.2 is intentional with a dated catch-up.
5. **Tag pipeline** — freeze pin record, full CI, metal checklist, `omahedron-X.Y.Z`. Maintainer GO to tag; agents do not tag.
6. **Nix verbs** — one page + one entrypoint that matches or beats nixarchy for search/add/remove/apply/update.
7. **Cache** — substituter in `install.md`; CI proves it.
8. **Scorecard** — first checked-in `schema/scorecard.json`.
9. **README rewrite** — competitive, honest, henrysipp-disambiguated. No “best” until §4.5 allows.
10. **Agent surface** — stub banners stable; optional Lapis coexistence documented.

### 5.1 Suggested acceptance tests (add, do not only document)

- Eval `omarchy.enable=true; profile=desktop` and assert Steam/Docker/`allowUnfree`-global are off.
- Grep tree for `omarchy-nix/` home paths used as locators; count must be 0.
- Run a stub and regex-match the banner.
- `nix flake lock --update-input omarchy-src` against a new tag must fail CI until ledger pin moves in the same commit.

## 6. Voice and claims

- Unofficial. Not Basecamp, not 37signals, not Omacom.
- Credit zicochaos for glue; credit basecamp/omarchy for the desktop.
- Never say “pixel-perfect” without T4 metal-green for that pin.
- Never say “431 commands” without pointing at the lockfile and the pin.
- Prefer “trailing-stable vendor port” to “distro.”

## 7. Pointers in this repo

| Artifact | Role |
|---|---|
| [SPEC.md](../SPEC.md) | Frozen product spec; change with ADR |
| [AGENTS.md](../AGENTS.md) | Operator rules |
| [DECISIONS.md](../DECISIONS.md) | ADRs |
| [COMPAT.md](COMPAT.md) | Gap ledger prose |
| [UPSTREAM.md](UPSTREAM.md) | Bump philosophy |
| [CHANNELS.md](CHANNELS.md) | Channel state machine |
| [schema/scripts.lock.json](../schema/scripts.lock.json) | Command classes |
| [schema/packages.map.json](../schema/packages.map.json) | Package classes |
| [checklists/metal.md](../checklists/metal.md) | Ship gate |
| [pkgs/omarchy.nix](../pkgs/omarchy.nix) | Vendor derivation |
| [modules/nixos/default.nix](../modules/nixos/default.nix) | System integration |
| [modules/home-manager/default.nix](../modules/home-manager/default.nix) | User seed |
| This file | Competitive bar, schema, rubric for agents |

If this file and [SPEC.md](../SPEC.md) disagree on module defaults (kitchen sink vs thin desktop), this file wins until SPEC is revised by ADR. Thin default is now a competitive requirement, not a taste preference.
