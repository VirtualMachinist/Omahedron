# Installing Omahedron

This is the long form of the README's quick start. It covers a fresh machine, an existing NixOS install, the first build, daily use, and the knobs people ask about most.

- [Requirements](#requirements)
- [Fresh machine](#fresh-machine)
- [Existing NixOS install](#existing-nixos-install)
- [First build: use the Hyprland cache](#first-build-use-the-hyprland-cache)
- [First login](#first-login)
- [Updating](#updating)
- [Installing and removing packages](#installing-and-removing-packages)
- [Rolling back](#rolling-back)
- [Common options](#common-options)
- [Virtual machine](#virtual-machine)
- [Troubleshooting](#troubleshooting)
- [Turning it off](#turning-it-off)

## Requirements

| | |
|---|---|
| Architecture | `x86_64-linux` only. The module refuses other systems at evaluation time. |
| NixOS | 26.05. The modules also evaluate on the 26.11 prerelease, but 26.05 is the tested pair. |
| Flakes | `nix.settings.experimental-features = [ "nix-command" "flakes" ]` |
| Boot | systemd-boot on UEFI is what the reference configuration uses. Limine is an Arch-side detail Omahedron does not carry. |
| Memory | 8 GB is the baseline machine. Less has not been tested. |
| GPU | Intel integrated graphics is the baseline. Anything Hyprland 0.56 supports should work; Nvidia follows the usual NixOS Hyprland caveats. |
| Disk | Plan for a few GB of store growth. Hyprland and its Mesa come from a binary cache once it is registered (see [First build](#first-build-use-the-hyprland-cache)). |

## Fresh machine

Omahedron does not ship an ISO. Install NixOS the normal way, then add Omahedron to the flake.

1. Boot the [NixOS minimal ISO](https://nixos.org/download/) and install as usual. Use UEFI with systemd-boot. If you want disk encryption, set up LUKS at this stage; Omahedron has an option to make the login flow sensible on an encrypted disk (see [Common options](#common-options)).
2. Reboot into the new system. Make sure networking works.
3. Convert `/etc/nixos` to a flake if it is not one already. The snippets in the next section are a complete `flake.nix` and `configuration.nix` you can drop in beside the generated `hardware-configuration.nix`.
4. Continue with [Existing NixOS install](#existing-nixos-install).

## Existing NixOS install

Omahedron is a NixOS module plus a Home Manager module. You import both, set `omarchy.enable = true`, and rebuild.

### `flake.nix`

```nix
{
  description = "my NixOS box running Omahedron";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    omahedron.url = "github:VirtualMachinist/Omahedron";

    # Optional. On nixos-26.05 this deduplicates nixpkgs so you download
    # one copy instead of two. If you run a different nixpkgs branch, leave
    # it out: Omahedron's packages then build against the nixpkgs they were
    # tested with.
    # omahedron.inputs.nixpkgs.follows = "nixpkgs";
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

Home Manager is reused from Omahedron's own pinned input so you do not need a second one. If your flake already has Home Manager wired in, keep yours and just add `omahedron.homeManagerModules.default` to `home-manager.sharedModules`.

To pin a specific release instead of tracking `main`, put the tag in the URL:

```nix
omahedron.url = "github:VirtualMachinist/Omahedron/omahedron-4.0.2";
```

### `configuration.nix`

```nix
{ pkgs, ... }:
{
  # The Omarchy update and install menus look up
  # nixosConfigurations."$(hostname)" in your flake, so this must match the
  # attribute name in flake.nix.
  networking.hostName = "mybox";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # One line enables the whole system layer: vendored Omarchy on PATH,
  # OMARCHY_PATH, the Hyprland session under uwsm, SDDM with the Omarchy
  # theme, Plymouth, PipeWire, NetworkManager, Bluetooth, and the Hyprland
  # binary cache.
  omarchy.enable = true;

  # Identity, seeded into git and the shell on first login. No prompt.
  omarchy.full_name = "Ada Lovelace";
  omarchy.email_address = "ada@example.com";
  omarchy.timezone = "Europe/London";

  # Desktop defaults. All have sensible defaults; override what you want.
  omarchy.theme = "tokyo-night";   # any of the 22 stock themes, or your own
  omarchy.terminal = "ghostty";    # foot, ghostty, alacritty, or kitty
  omarchy.scale = 1;               # 2 for HiDPI

  # Menu-managed packages. The Install and Remove menus write this file
  # inside your flake; the guard keeps evaluation working before the first
  # install creates it.
  omarchy.managedPackagesFile =
    if builtins.pathExists ./omarchy-packages.json then ./omarchy-packages.json else null;

  users.users.ada = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "networkmanager" ];
    initialHashedPassword = "…";   # generate with: mkpasswd -m sha-512
  };

  # The Home Manager module is already shared with all users from flake.nix.
  # This block carries only the per-user settings.
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

The reference configuration this repository builds in CI is [example/configuration.nix](../example/configuration.nix). Every `omarchy.*` option is documented in [options.md](options.md).

## First build: use the Hyprland cache

Omahedron pins Hyprland from its own flake input rather than taking whatever stable nixpkgs carries. The module registers `hyprland.cachix.org` as a substituter so nobody compiles a compositor, but on a machine that has never run the module, that setting only takes effect after the switch completes. Pass the cache on the command line the first time:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#mybox \
  --option extra-substituters https://hyprland.cachix.org \
  --option extra-trusted-public-keys hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=
```

Every later rebuild is just:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#mybox
```

If you skip the options, the build still succeeds. It compiles Hyprland, Mesa and friends locally, which takes a long time and can exhaust memory on a small machine.

## First login

Reboot, or restart the display manager. SDDM comes up with the Omarchy theme. Log in and Hyprland starts under uwsm with the Omarchy Lua configuration.

On the first login Home Manager seeds your editable files as real files, not store symlinks, so the Setup menu, `omarchy-refresh-config` and `omarchy-theme-set` work exactly the way upstream expects:

- `~/.config/hypr/hyprland.lua`, the entry point that dispatches into `$OMARCHY_PATH`, plus the user override stubs it loads
- `~/.config/hypr/monitors.lua`, from `omarchy.monitors` and `omarchy.scale`
- `~/.config/omarchy/`, your user-side Omarchy config
- `~/.local/state/omarchy/current/theme`, pointing at `omarchy.theme`

The theme and monitor options are seeds. They are applied once, when those files do not exist yet. After that the files are yours, and changing the Nix option is a no-op until you remove the file. This is deliberate: it is how Omarchy's own runtime tooling keeps working.

Then press <kbd>Super</kbd>+<kbd>Enter</kbd> for a terminal and <kbd>Super</kbd>+<kbd>Space</kbd> for the launcher. Keybindings are Omarchy's; the [Omarchy manual](https://omarchy.org/manual) applies.

Two NixOS-side defaults worth knowing on day one:

- **SSH is on, keys only.** The module enables sshd with password and keyboard-interactive authentication off. Add `openssh.authorizedKeys.keys` to your user for remote access, or opt into passwords explicitly with `services.openssh.settings.PasswordAuthentication = true`.
- **Fish is the default interactive shell**, as upstream. Bash remains the script runtime. Set `omarchy.fish.enable = false` to keep your existing default shell, or set `users.users.<name>.shell` per user.

## Updating

Omarchy's **Update** menu entry, and the `omarchy-update` command, do on NixOS what they do on Arch: refresh the desktop and the system. Underneath, they run `nix flake update` on your configuration flake and then `nixos-rebuild switch`.

For that to work the scripts need to find your flake. They check, in order:

1. `$OMARCHY_NIX_FLAKE`, if set (a flake directory or the path to its `flake.nix`)
2. `~/omarchy-nix/`
3. `~/Projects/omarchy-nix/`
4. `/etc/nixos/`

The first candidate whose `nixosConfigurations` contains an entry for your hostname wins. If your flake lives at `/etc/nixos` with a matching hostname, nothing to configure. If it lives elsewhere, set the variable once:

```nix
environment.sessionVariables.OMARCHY_NIX_FLAKE = "/home/ada/nixos-config";
```

An explicit but invalid `OMARCHY_NIX_FLAKE` fails loudly rather than falling back to another checkout.

Because the Omahedron input is pinned in your `flake.lock`, a flake update also picks up Omahedron's own bumps, including the next Omarchy tag when it lands on the branch you follow. See [CHANNELS.md](CHANNELS.md) for how those bumps are scheduled.

## Installing and removing packages

The **Install** and **Remove** menus, and the `omarchy-install-*` commands behind them, do not run pacman. They run `omarchy-nix-add` and `omarchy-nix-remove`, which:

1. Resolve your flake the same way `omarchy-update` does.
2. Add or remove the package in `<flake>/omarchy-packages.json`, with a lock held for the whole transaction and a hash-checked rollback if the rebuild fails.
3. Register the file with `git add -N` when the flake is a git checkout, so the flake snapshot includes it.
4. Run `nixos-rebuild switch`.

Your `omarchy.managedPackagesFile` option folds that JSON into `environment.systemPackages` at evaluation time. That is why the option is set with a `pathExists` guard: the file does not exist until the first menu install, and a non-null path that does not exist fails evaluation on purpose so menu installs never silently vanish.

Upstream features that are more than a package (Steam, Tailscale, 1Password, Ollama and the like) map to the matching NixOS feature block in the same JSON.

Anything you would rather manage by hand goes in your configuration as usual. To drop one of Omahedron's default apps without forking the module:

```nix
omarchy.exclude_packages = [ "obsidian" "signal-desktop" ];
```

Unfree packages are allowed by default for the apps Omarchy selects, because most of them are unfree and an install loop that dies on a license prompt is not the desktop anyone asked for. Override `nixpkgs.config.allowUnfreePredicate` if you want a free-only machine.

## Rolling back

This is the reason many people are here. Every `nixos-rebuild switch` creates a new generation, and every generation is a boot menu entry.

- At boot, pick an older generation from the systemd-boot menu.
- From a running system, `sudo nixos-rebuild switch --rollback` returns to the previous generation.
- To pin an older Omahedron, put its tag in `omahedron.url` and rebuild.

Home Manager state under `$HOME` is not part of a generation. Your edited config files stay as they are across rollbacks, which is what you want.

## Common options

The full reference is [options.md](options.md). These are the ones that come up most.

**Encrypted disk, one password.** On a LUKS install you already typed a passphrase at boot. Skip the second prompt at SDDM:

```nix
omarchy.autologin.user = "ada";
```

**Monitors.** Hyprland directives, in the same shape upstream uses, seeded into `monitors.lua` on first login:

```nix
omarchy.monitors = [ "DP-1, 2560x1440@120, 0x0, 1" ];
omarchy.scale = 2;   # HiDPI
```

**Fingerprint unlock** for the lock screen, where the hardware has a reader:

```nix
omarchy.fingerprint.enable = true;
# then, per user: fprintd-enroll
```

**Keep Bash** as the default shell:

```nix
omarchy.fish.enable = false;
```

**Cross-architecture Docker builds**, which upstream enables unconditionally and Omahedron makes opt-in:

```nix
omarchy.binfmtEmulatedSystems = [ "aarch64-linux" ];
```

**Plymouth and the SDDM theme** can each be turned off with `omarchy.plymouth.enable` and `omarchy.sddm.theme`.

## Virtual machine

You can build the reference configuration as a QEMU VM straight from this repository:

```sh
nix build .#nixosConfigurations.example.config.system.build.vm
QEMU_OPTS="-device virtio-gpu-pci" ./result/bin/run-nixos-vm
```

Log in as `omarchy` with password `omarchy`. Use `virtio-gpu-pci`; a software framebuffer will not draw the Quickshell shell correctly and tells you nothing about the desktop.

A VM is a pre-gate for development, not verification. Omahedron's own release gate is bare metal on the baseline machine. See [METAL.md](METAL.md) if you are curious why.

## Troubleshooting

**`omarchy-nix supports x86_64-linux only`**
The module is being evaluated for another architecture. Omahedron is x86_64 only.

**`omarchy.managedPackagesFile points at a missing file`**
The option is set to a path that does not exist. Use the `pathExists` guard shown above, or set it to `null` until the first menu install.

**Update or Install menu says no consumer flake was found**
The scripts could not find a flake whose `nixosConfigurations` has an entry named after this machine. Check that `networking.hostName` matches the attribute in `flake.nix`, or set `OMARCHY_NIX_FLAKE`.

**The first build is compiling Hyprland**
The Hyprland cache was not known to the daemon yet. Interrupt and re-run with the `--option` flags from [First build](#first-build-use-the-hyprland-cache).

**I changed `omarchy.theme` and nothing happened**
Theme and monitor options are seeds. Run `omarchy-theme-set <name>`, or remove `~/.local/state/omarchy/current/theme` and switch again.

**An `omarchy-*` command prints `omahedron: stub:`**
That command depends on something Arch-specific such as pacman or the Limine boot chain. The message names the NixOS mechanism to use instead. The full list, with reasons, is in [COMPAT.md](COMPAT.md).

## Turning it off

Set `omarchy.enable = false` in both the system and the Home Manager block and rebuild. Importing the module with it disabled has no side effects; CI checks that. Files seeded under `$HOME` are left in place for you to remove.
