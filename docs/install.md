# Installing Omahedron

This is the long form of the README's quick start. It covers a fresh machine, an existing NixOS install, the first build, daily use, and the knobs people ask about most.

- [Requirements](#requirements)
- [Fresh machine](#fresh-machine)
- [Existing NixOS install](#existing-nixos-install)
- [First build: use the Hyprland cache](#first-build-use-the-hyprland-cache)
- [First login](#first-login)
- [Updating](#updating)
- [Nix verbs (search / add / remove / apply / update)](#nix-verbs-search--add--remove--apply--update)
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

Omahedron does not ship an ISO **on this tag**. ADR-0025 puts an Omahedron installer in product: first `omarchy setup` on an existing NixOS, then a NixOS-shaped ISO (systemd-boot, generations — not Limine/Snapper). Until those ship, install NixOS the normal way, then add Omahedron to the flake.

1. Boot the [NixOS minimal ISO](https://nixos.org/download/) and install as usual. Use UEFI with systemd-boot. If you want disk encryption, set up LUKS at this stage; Omahedron has an option to make the login flow sensible on an encrypted disk (see [Common options](#common-options)).
2. Reboot into the new system. Make sure networking works.
3. Convert `/etc/nixos` to a flake if it is not one already. The snippets in the next section are a complete `flake.nix` and `configuration.nix` you can drop in beside the generated `hardware-configuration.nix`.
4. Continue with [Existing NixOS install](#existing-nixos-install).
