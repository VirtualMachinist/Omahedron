# AGENTS.md — Omahedron on this host

This host is **unofficial Omahedron**: the Omarchy desktop on NixOS. Not Arch. Not Omacom-supported.

Humans use `omarchy`. Agents edit Nix.

**Humans** use `omarchy` — the command center, menus, SDDM, and the boot menu. They are never required to open a `.nix` file.

**You, the agent, edit Nix.** That is the durable system: the consumer flake on the G0 locator (`$OMARCHY_NIX_FLAKE`, then `/etc/nixos` with `nixosConfigurations."$(hostname)"`), `omarchy.*` options in `configuration.nix`, `omarchy-packages.json` (menu-managed packages), and the `home-manager.users.<name>` block. Read `hardware-configuration.nix`; do not clobber or regenerate it. Do not fight the flake with shell one-liners; apply with `nixos-rebuild switch` (or `omarchy setup …` / `omarchy pkg add|drop` / `omarchy update`, which edit the same files).

Rule: humans use `omarchy`; agents edit Nix.

This file is installed at `/etc/omahedron/AGENTS.md`. `omarchy debug` prints this path; `$HOME/AGENTS.md` may mirror it for cwd-only harnesses. The Omahedron *source* repository's `AGENTS.md` is for people changing the port — not this runtime copy.

---

## Vendor rule

Everything the user sees comes from `$OMARCHY_PATH` (the pinned Omarchy tree in the store). Read `bin/omarchy-*`, `default/hypr/…`, `shell/…`, and `themes/…` freely. Do not restyle Quickshell or Hyprland in Nix. User overrides live under `~/.config/`.

## G0 locator

Nix-facing `omarchy` commands resolve the consumer flake in order:

1. `$OMARCHY_NIX_FLAKE` — a directory containing `flake.nix`, or the path to `flake.nix` itself
2. `/etc/nixos` — when `nixosConfigurations."$(hostname)"` exists

Home-directory scavenger paths are not supported locators. An explicit but invalid `OMARCHY_NIX_FLAKE` fails closed.

## Seed rule

Theme and monitors are seeded into `$HOME` on first login (`~/.local/state/omarchy/current/theme`, `~/.config/hypr/monitors.lua`, and related Hyprland entry files). After that, `omarchy.theme` and `omarchy.monitors` are no-ops until the seeded file is removed. Humans change themes with `omarchy theme set`.

## Stub banner contract

Commands that print a first line matching `omahedron: (stub|na|wrap|host): <reason>` are declarative stand-ins — read the note, set the option, rebuild. Example first line: `omahedron: stub: pacman`. Do not work around a stub by editing `/etc`, PAM, bootloader, or systemd units imperatively.

## Rollback

`omarchy rollback` is the previous NixOS generation. It does **not** roll back `$HOME` — Home Manager state and edited files under `~/.config` stay as they are. `omarchy rollback --list` shows generations; the **systemd-boot menu** at boot is the brick path.

## Platform and profile

**x86_64-linux** only. `omarchy setup` refuses other systems.

**Thin** desktop by default (`omarchy.profile = "desktop"`). `workstation` and unfree catalog installs are explicit opt-ins (`omarchy.setup profile workstation`, `omarchy.unfree.enable`).

## Where things are

| What | Where |
| --- | --- |
| Active system | `/run/current-system` |
| System logs | `journalctl` |
| Update log | `/tmp/omarchy-update.log` |
| Omarchy state | `~/.local/state/omarchy` |
| Agent diagnostics | `omarchy debug --no-sudo --print` |

In agent sessions, always use `omarchy debug --no-sudo --print`.

## What you edit

| Artifact | Purpose |
| --- | --- |
| `flake.nix` / `configuration.nix` | G0 locator, `omarchy.*`, `inputs.omahedron` pin |
| `hardware-configuration.nix` | Hardware — read only; never regenerate |
| `omarchy-packages.json` | Menu-managed packages (`omarchy pkg add\|drop`) |
| `home-manager.users.<name>` | User session defaults |

Each successful `nixos-rebuild switch` adds a boot-menu generation. Rollback moves the system generation only; `$HOME` is unchanged.
