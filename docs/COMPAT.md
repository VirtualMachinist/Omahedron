# COMPAT.md

Human ledger of every stub and NixOS-ism. Machine source of truth is [schema/scripts.lock.json](../schema/scripts.lock.json) and [schema/packages.map.json](../schema/packages.map.json). If prose and JSON disagree, JSON wins and this file must be updated in the same commit.

Status at pin v4.0.2: CI directly enforces both JSON ledgers through `checks.omarchy-ledgers`. The script inventory covers **431 upstream commands** (329 vendor, 32 wrap, 70 stub), the `pacman` N/A policy row, and five port helpers. The package map covers **206 names from both upstream install lists**, plus six explicit entries outside those lists. Manifest data files are no longer presented as packages.

## How to read a row

| Field | Meaning |
|---|---|
| id | stable slug |
| class | `vendor` `wrap` `stub` `host` `na` `drop` |
| upstream | path or command in omarchy-src |
| stand-in | NixOS option, wrap script, or none |
| user-visible | yes if a menu, keybind, or first-run can reach it |
| since | first Omahedron tag that recorded it |

Classes are defined in [SCHEMA.md](SCHEMA.md).

## Must stay N/A or host-owned

These are the brief’s permanent gaps. They stay listed even after the inventory exists.

| id | class | upstream | stand-in | notes |
|---|---|---|---|---|
| pacman | na | pacman, yay, AUR, pkgs.omarchy.org | flake packages + rebuild | never install host pacman |
| channel-switcher-arch | na | official channel TUI as Arch implements it | change flake input | stub if a menu reaches it |
| official-kernel-pkg | na | linux-ptl / Omarchy Kernel `.pkg.tar.zst` | `boot.kernelPackages` | later optional derivation |
| limine-snapper-uki | na | Limine, Snapper, mkinitcpio UKI | systemd-boot + generations | |
| iso-apply | na | ISO, `omarchy-apply-system`, `omarchy-apply-hardware` | NixOS hardware modules | |
| mutable-usr | na | `/usr/share/omarchy`, `omarchy-dev-link` | store `$OMARCHY_PATH` | |
| omacom-support | na | Foundation patronage features that assume Arch | none | do not claim |
| plugins-arch-root | na | marketplace entries that pacman-install or write `/etc` as root | stub UI if present | ADR-0010 |
| mise-opt | na | mise tarball under `/opt` | nixpkgs / flakes / devshells | |
| day-one-vendor-kernel | na | same-week Dell/Intel kernels as Arch packages only | wait for nixpkgs | |

## Desktop targets that must match the pinned tag

When metal-green, these are not optional:

- One Quickshell process and its plugins
- Hyprland Lua bootstrap + `~/.config` overrides
- Theme engine (TOML + templates), live swap
- Default bindings
- First-run provisioning with Nix-seeded identity
- `omarchy-*` that are reached and classified `vendor` or `wrap`
- Fish interactive default (opt-out allowed)
- Agent surface: Cursor, Grok (v1); others first-class

## Known NixOS-isms (inherit and verify on first pin)

Recorded from zicochaos UPSTREAM.md. Re-verify against v4.0.2; do not copy blindly if the file moved.

| Area | Upstream | Omahedron | Why |
|---|---|---|---|
| Tree location | `/usr/share/omarchy` | `$out/share/omarchy` | store |
| Bin on PATH | `/usr/bin/omarchy-*` | `$OMARCHY_PATH/bin` prepended | session PATH |
| OMARCHY_PATH source | profile.d / dev-link | sessionVariables + uwsm env | no Arch dev-link |
| Theme render trigger | ISO chroot | HM activation | no ISO stage |
| First-run | `install/user/first-run/*.sh` | vendored provision on first login | invitation hooks pre-marked; Arch steps no-op |
| Hyprland package | Arch hyprland | flake input ≥0.56 | 26.05 nixpkgs lagged 0.55.4 at zico writing |
| Browser desktop id | `chromium.desktop` | alias `chromium-browser.desktop` | NixOS naming |
| Update | pacman + omarchy update | flake update + rebuild | wrap |

## Phased items (destination yes, not v1 gate)

| id | v1 class expected | later |
|---|---|---|
| webapps | stub or partial wrap | v1.1 wrap |
| voxtype | stub unless cheap | v1.2 |
| fingerprint | host / stub | v1.2 if hardware present |
| windows-vm | stub | v1.2 wrap-or-stub from call sites |

## Honesty rules (SecOps)

- A stub that says `na: pacman` is correct. A wrap that half-calls pacman is not.
- Do not mark metal-green from a VM.
- Do not delete a gap from this file because it is embarrassing. Move it to a new class with an ADR.

## Pin notes (v4.0.2)

| Item | Class | Notes |
|---|---|---|
| Upstream `version` file at tag v4.0.2 | host | File contents still read `4.0.0.alpha` at commit `346e69e1`. **Override active:** flake sets `omarchyVersion = "4.0.2"` (does not read the upstream file). Claimed desktop = Omarchy **v4.0.2**. |
| Hyprland flake input | wrap | Pinned to `github:hyprwm/Hyprland/v0.56.2` (not HEAD) for reproducible pre-tag / metal. |
| Hyprland Glaze dependency | wrap | `pkgs/hyprland.nix` supplies Glaze 7.2.0 as a fixed-output Nix dependency, matching v0.56.2 `CMakeLists.txt` (`find_package(glaze 7...<8)` / `GLAZE_VERSION v7.2.0`). The input's nixpkgs selects incompatible Glaze 8, triggering a network clone during configure. The compositor source and compiler remain upstream's; explicit consumer package assignments win. |
| NetworkManager before display-manager | wrap | `systemd.services.NetworkManager.before = ["display-manager.service"]` (no Requires). Fixes quickshell 0.3.0 first-boot NM race (basecamp/omarchy#7324); cherry-pick of zicochaos/omarchy-nix#4. |
| Menu NordVPN / ONCE delete patches | drop | zicochaos matched `disabled:` guards; v4.0.2 restored `when: ! omarchy-pkg-present …`. Patches retargeted to the `when` literals (still deleted: AUR-only ONCE; NordVPN waits on nixpkgs 26.11 `services.nordvpn`). |
| Menu mise-dir install guards | wrap | v4.0.2 install side uses `when: [[ ! -d … ]]` again (quattro briefly used `disabled:`). Added matching `--replace-fail` rewrites to `! omarchy-pkg-present`; remove-side `[[ -d … ]]` rewrites retained. |
| Remaining `--replace-fail` surface | wrap | Path + string audit against tag tree: only the above two families broke on the pin; others still match. Nix/CI / vendor confirm on first `nix flake check`. |
| Runtime classify: sudoless-docker ×2 + theme-set-browser-policy | stub | `declarative-note` in `pkgs/omarchy-runtime-manifest.nix`; menus `setup.security.sudoless-docker` / `remove.security.sudoless-docker` hidden. Lock rows stub (nixos-declarative). |
| Interactive shell | host | Fish and the vendored profile are enabled by default (ADR-0011), using `users.defaultUserShell`. Explicit host/account shells win; `omarchy.fish.enable = false` opts out. Bash remains the script runtime. |
| Automatic printer discovery | host | `services.printing.browsed.enable` defaults to `false`, matching the daemon removal in upstream v4.0.2 migration `1788009111.sh`; CUPS printing remains enabled. Consumers may explicitly enable discovery through NixOS. The Arch migration and hardening drop-in are not applied, and existing generated queues are not deleted; stale `implicitclass` queues may need manual removal or reconfiguration. |
| Ledger enforcement | vendor/wrap/stub | Classification now describes the shipped command body. A retained installer that calls a package stub is still vendor-class; that does not claim a complete install flow. Package attributes marked `available` are validated counterparts, not claims of default installation. |
| Stub output debt | stub | Inherited declarative stubs mostly print `NixOS: …` and exit 0, rather than the ADR-0009 parseable prefix. Predicate/silent no-ops document their exit behavior in JSON. This check records the current behavior; prefix normalization remains follow-up work. |
| Optional hardware mappings | gap | `intel-ipu7-camera`, `intel-lpmd`, `dell-xps-touchpad-haptics`, `apple-bcm-firmware`, `apple-t2-audio-config`, `t2fanrd`, and `qmk-hid` have no audited mapping. None is advertised as installed or supported. |
| Dropbox removal helper mode | vendor | Upstream `bin/omarchy-remove-service-dropbox` lacks executable bits, which the package preserves. JSON records `executable: false`; the menu uses the Nix catalog removal handler. Direct execution is unavailable. |
