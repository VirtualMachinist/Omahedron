<p align="center">
  <a href="https://github.com/VirtualMachinist/Omahedron">
    <img src="docs/brand/omahedron-mark-512.png" alt="Omahedron" width="220">
  </a>
</p>

<h1 align="center">Omahedron</h1>

<p align="center">
  <strong>The Omarchy desktop, on NixOS.</strong><br>
  Stable by schedule. Rollback by design. Same pixels, same keys.
</p>

<p align="center">
  <a href="https://github.com/VirtualMachinist/Omahedron/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/VirtualMachinist/Omahedron/ci.yml?branch=main&style=flat&colorA=222222&colorB=8FD14F&label=ci" alt="CI"></a>
  <a href="https://github.com/basecamp/omarchy/releases/tag/v4.0.2"><img src="https://img.shields.io/badge/Omarchy-v4.0.2-8FD14F?style=flat&colorA=222222" alt="Omarchy v4.0.2"></a>
  <a href="https://nixos.org"><img src="https://img.shields.io/badge/NixOS-26.05-5277C3?style=flat&colorA=222222&logo=nixos&logoColor=white" alt="NixOS 26.05"></a>
  <a href="https://github.com/hyprwm/Hyprland/releases/tag/v0.56.2"><img src="https://img.shields.io/badge/Hyprland-0.56.2-58C7F3?style=flat&colorA=222222" alt="Hyprland 0.56.2"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/VirtualMachinist/Omahedron?style=flat&colorA=222222&colorB=8FD14F" alt="MIT license"></a>
  <a href="https://hedronite.com"><img src="https://img.shields.io/badge/Hedronite-hedronite.com-8FD14F?style=flat&colorA=222222" alt="Hedronite"></a>
  <a href="https://x.com/Hedronite"><img src="https://img.shields.io/badge/@Hedronite-000000?style=flat&colorA=222222&logo=x&logoColor=white" alt="@Hedronite on X"></a>
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> ·
  <a href="#what-you-get">What you get</a> ·
  <a href="#omachron-the-release-schedule">Omachron</a> ·
  <a href="#how-it-works">How it works</a> ·
  <a href="docs/install.md">Install guide</a> ·
  <a href="docs/options.md">Options</a> ·
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  Built by <a href="https://hedronite.com">Hedronite</a>'s <a href="https://github.com/VirtualMachinist">VirtualMachinist</a>.
  Desktop by <a href="https://omarchy.org">Omarchy</a>. Not affiliated with Omarchy, Omacom, or 37signals.
</p>

---

Omahedron is the [Omarchy](https://omarchy.org) desktop running on NixOS. The same Hyprland session, the same Quickshell bar, launcher, menus and lock screen, the same twenty-two themes with live swap, the same keybindings, the same `omarchy-*` commands. All of it comes straight from the official Omarchy source tree, pinned to a tagged upstream release and shipped as a Nix flake.

It exists for **Omarchs who want NixOS underneath**: declarative configuration, atomic upgrades, and rollback to any previous generation from the boot menu. If Arch's pace is the one thing keeping you off Omarchy, this is the way in. If you already run NixOS and want Omarchy's desktop without maintaining a rice, this is the way in too.

Omahedron is not a competing distro and not a rewrite. It is Omarchy's own desktop tree, vendored into the Nix store and driven by NixOS. We are members of the Omarchy community on NixOS instead of Arch, and we send fixes upstream. DHH himself has [looked at Nix](https://x.com/dhh/status/1952768570003272105) and pointed people toward a NixOS port. Omahedron is what that idea looks like carried all the way through.

**431** upstream commands classified · **329** shipped untouched · **206** upstream packages mapped · **18** CI checks · **3** VM test suites · **1** Quickshell process

## Quick start

Three steps on an existing NixOS install. The [install guide](docs/install.md) has the long version, including a fresh-machine walkthrough, the flake-follows question, and the first-build cache tip.

**1. Add Omahedron to your flake.**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    omahedron.url = "github:VirtualMachinist/Omahedron";
  };

  outputs = { nixpkgs, omahedron, ... }: {
    nixosConfigurations.mybox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        omahedron.nixosModules.default
        omahedron.inputs.home-manager.nixosModules.home-manager
        { home-manager.sharedModules = [ omahedron.homeManagerModules.default ]; }
      ];
    };
  };
}
```

**2. Turn it on in `configuration.nix`.**

```nix
{ pkgs, ... }:
{
  networking.hostName = "mybox";   # must match the nixosConfigurations key above
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  omarchy.enable = true;
  omarchy.full_name = "Ada Lovelace";
  omarchy.email_address = "ada@example.com";
  omarchy.timezone = "Europe/London";
  omarchy.theme = "tokyo-night";    # any of the 22 stock themes
  omarchy.terminal = "ghostty";     # foot, ghostty, alacritty, or kitty

  # Packages installed from the Omarchy menus land here, declaratively.
  omarchy.managedPackagesFile =
    if builtins.pathExists ./omarchy-packages.json then ./omarchy-packages.json else null;

  users.users.ada = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "networkmanager" ];
    initialHashedPassword = "…";    # mkpasswd -m sha-512
  };

  home-manager.users.ada = {
    home.username = "ada";
    home.homeDirectory = "/home/ada";
    home.stateVersion = "26.05";
    omarchy.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "26.05";
}
```

**3. Build, reboot, log in.**

```sh
sudo nixos-rebuild switch --flake /etc/nixos#mybox
```

Log in at the SDDM greeter, press <kbd>Super</kbd>+<kbd>Enter</kbd>, and you are in Omarchy. The full option surface is in [docs/options.md](docs/options.md); the reference configuration this repo tests against is [example/configuration.nix](example/configuration.nix).

> [!TIP]
> The very first build pulls a pinned Hyprland from the Hyprland binary cache once the module has registered it. On a brand-new machine that registration lands in the same switch, so pass the cache on the command line the first time to avoid compiling Hyprland from source. The [install guide](docs/install.md#first-build-use-the-hyprland-cache) shows the one-liner.

## What you get

Everything below is Omarchy's own code, running from the Nix store.

| | Omarchy on Arch | Omahedron on NixOS |
|---|---|---|
| Compositor | Hyprland 0.56 with the Lua bootstrap | Same Hyprland, pinned at 0.56.2, with the same Lua bootstrap and your overrides in `~/.config/hypr` |
| Shell | One Quickshell process for bar, launcher, menus, notifications, OSDs, lock, polkit | The same single Quickshell process |
| Themes | 22 stock themes, TOML plus templates, live swap | Same engine, same themes, same live swap, plus your own under `~/.config/omarchy/themes` |
| Commands | `omarchy-*` scripts on `PATH` | Same scripts on `PATH`, sourced from the pinned upstream tag |
| Shell | Fish by default, Bash for scripts | Same, with an opt-out |
| First run | Interactive identity prompt | Identity seeded from your Nix options, no prompt |
| Apps | Omarchy-owned apps from the Omarchy repo | The same apps packaged under `pkgs/` when nixpkgs lacks them |
| Update | `omarchy update` | The same menu entry runs `nix flake update` and `nixos-rebuild switch` |
| Install / Remove menus | pacman and yay | Writes `omarchy-packages.json` in your flake and rebuilds, so every install is declarative and rollback-safe |
| Undo | Snapper snapshots | Every generation in the boot menu |

### What stays on Arch, on purpose

Omahedron rebuilds the desktop layer. The operating-system layer belongs to NixOS, and every place the two meet is written down rather than papered over. The full ledger lives in [docs/COMPAT.md](docs/COMPAT.md) with a machine-readable copy in [schema/](schema/) that CI enforces.

| Upstream | On Omahedron |
|---|---|
| pacman, yay, AUR, pkgs.omarchy.org | Flake packages and a rebuild. Never a host pacman. |
| Limine, Snapper, mkinitcpio UKI | systemd-boot and NixOS generations |
| The Omarchy ISO, `omarchy-apply-system`, `omarchy-apply-hardware` | The NixOS installer and your `hardware-configuration.nix` |
| The Omarchy Kernel as an Arch package | The kernel from nixpkgs |
| Mutable `/usr/share/omarchy` | An immutable store path in `$OMARCHY_PATH` |
| Omacom support | Not claimed. Omahedron is unofficial. |

## Omachron: the release schedule

Omahedron trails Omarchy on purpose. Omachron is the name of that cadence.

- **Every release claims a desktop.** The user-facing version is Omarchy's own: `desktop = Omarchy 4.0.2`, frozen on a date, recorded in the module and the changelog. Flake tags follow it as `omahedron-4.0.2`.
- **Patch and security tags ship immediately.** When Omarchy publishes a `4.0.x`, a bump opens the same day with no soak. Security notes jump the queue.
- **Minor and major releases wait for the train to stop.** A `4.1.0` is pinned once its follow-up patches have settled, not on release day.
- **Every release names its gaps.** The changelog line is always `parity with Omarchy vX.Y.Z; known gaps: …`.

| Channel | `omarchy-src` | nixpkgs | For |
|---|---|---|---|
| `stable` (default) | Official tag `vX.Y.Z` | nixos-26.05 | Daily driving |
| `rc` | Official RC tag, when one exists | Same as stable | Trying the next release early |
| `edge` | Omarchy `master` | nixos-unstable | Maintainer dogfood. Not supported, never 1:1. |

Policy detail, including the bump state machine, is in [docs/CHANNELS.md](docs/CHANNELS.md).

### Current pin

| | |
|---|---|
| Desktop | Omarchy **v4.0.2**, released 2026-08-31 |
| Upstream commit | `346e69e1` |
| NixOS | 26.05, with a planned cutover to 26.11 |
| Hyprland | 0.56.2 |
| Baseline hardware | Dell Latitude 5420, 8 GB RAM, Intel iGPU |

Omahedron 4.0.2 runs on bare metal today and has passed smoke testing on the baseline machine. The first tagged release, `omahedron-4.0.2`, lands once the full [hardware checklist](checklists/metal.md) is signed off. Until then, track `main`.

## How it works

One rule drives the whole design: **if the user can see it, it comes from Omarchy. If NixOS already models it, declare the NixOS option.** Nothing the user touches gets rewritten in Nix, not the Quickshell widgets, not the theme templates, not the script router.

- The pinned Omarchy tree is vendored into the store as `$OMARCHY_PATH`, the same variable upstream uses, and `$OMARCHY_PATH/bin` is prepended to the session `PATH`.
- Upstream scripts that need an Arch-ism are patched in place with `substituteInPlace --replace-fail`, so a silent upstream change fails the build instead of shipping broken.
- Every one of the 431 upstream commands is classified in a ledger as `vendor` (shipped untouched), `wrap` (same name, NixOS mechanism underneath), or `stub` (prints why it does not apply here, never calls pacman). CI fails when a new upstream command appears unclassified.
- Home Manager seeds the user-editable files once, as real files, so the Omarchy Setup menu and `omarchy-refresh-config` keep working exactly as upstream expects.
- Hyprland comes from its own pinned flake input with a matching Mesa, so the compositor is the version Omarchy's Lua config was written for regardless of what stable nixpkgs carries.

<details>
<summary><strong>Repository map</strong></summary>

```
flake.nix                 # inputs: nixpkgs, home-manager, hyprland, omarchy-src
config.nix                # the omarchy.* option surface, shared by both modules
modules/nixos/            # session, greeter, audio, portals, firmware, cache
modules/home-manager/     # user seeds, theme state, first-run
pkgs/omarchy.nix          # vendored upstream tree, patched, into $OMARCHY_PATH
pkgs/<name>.nix           # Omarchy-owned apps that nixpkgs does not carry
schema/                   # script ledger, package map, JSON schemas
checks/                   # ledger enforcement and stub behaviour tests
tests/                    # NixOS VM suites: desktop, Fish, UX
example/configuration.nix # the reference consumer config CI builds
docs/                     # install, options, COMPAT, CHANNELS, UPSTREAM, brand
```

</details>

## Contributing

Issues and pull requests are welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md), which covers the validation workflow, then [AGENTS.md](AGENTS.md) and [DECISIONS.md](DECISIONS.md) for the rules the tree already follows. Two of them matter most: desktop pixels come from Omarchy, and any new upstream command gets classified in the ledger in the same change.

When something we fix turns out to be an Omarchy bug rather than a NixOS-ism, it goes upstream. Being a good citizen of the Omarchy community is part of the job, not a side quest.

## Credits and license

Omahedron is built and maintained by [Hedronite](https://hedronite.com). The desktop is [Omarchy](https://omarchy.org) by DHH, Basecamp and Omacom. The vendor-into-store architecture and the first module design derive from [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix), forked with license and credit intact. Full attribution is in [docs/CREDITS.md](docs/CREDITS.md).

MIT. See [LICENSE](LICENSE). The Omahedron mark is Hedronite's; usage notes are in [docs/brand/](docs/brand/).
