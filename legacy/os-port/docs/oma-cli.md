# oma-cli — humans drive `omarchy`, agents edit Nix

Workstream doc for ADR-0025 ([DECISIONS.md](DECISIONS.md)). **oma-cli** is the workstream name only. The user-facing binary is the vendored **`omarchy`** command center. There is no second CLI brand.

**`tetra-cli` is not this product.** That name is reassigned to an unrelated function. Do not add a `tetra-cli/` tree here and do not read one as the Omahedron CLI.

## One sentence

Humans drive Omahedron with `omarchy` the way they drive Arch Omarchy. Agents edit Nix. The machine is durable NixOS.

## The split that must not collapse

| Who | Sees | Does |
|---|---|---|
| **Human** | `omarchy`, menus, SDDM, boot generations, sudo, “this takes minutes” | Never required to open `flake.nix` / `configuration.nix` |
| **Agent** | Consumer flake, `omarchy.*`, `omarchy-packages.json`, `$OMARCHY_PATH`, generations, stub banners | **Edits Nix.** Troubleshoots Nix. Does not pretend the box is Arch |

Hiding Nix from humans is the product. Hiding Nix from agents is a bug.

## Command center

Upstream already routes `omarchy theme set` → `omarchy-theme-set`. Keep that router. Help copy describes the NixOS meaning; pacman / Limine / Snapper are not the happy path. Remaining stubs print `omahedron: stub:` / `na:` on the first line (see [docs/COMPAT.md](docs/COMPAT.md)). Wraps keep the Arch route names so muscle memory works.

Packages are one list, `<flake>/omarchy-packages.json`, folded by `omarchy.managedPackagesFile`. Menus and `omarchy pkg add|drop` write it, then rebuild.

Flake locator (G0): `$OMARCHY_NIX_FLAKE`, then `/etc/nixos` with `nixosConfigurations."$(hostname)"`. Fail closed.

## Verbs

| Intent | Human types | Under the hood |
|---|---|---|
| Identity | `omarchy setup` | `omarchy.full_name` / `email_address` / `timezone` + `users.users.*`, then rebuild |
| Profile / unfree | `omarchy setup profile …` / `omarchy setup unfree on\|off` | `omarchy.profile` / `omarchy.unfree.enable` |
| Terminal | `omarchy default terminal` | live vendor change **and** `omarchy.terminal` persisted |
| Fingerprint / autologin | setup verbs | `omarchy.fingerprint.enable` + `fprintd-enroll`; `omarchy.autologin.user` |
| Pin / channel | `omarchy pin`, `omarchy channel set` | move the `omahedron` flake input to a tag; rebuild |
| Update | `omarchy update` | flake update + rebuild; prints pin, `omarchy-src` tag, newest stable, channel |
| Packages | `omarchy pkg add\|drop` | `omarchy-nix-add` / `omarchy-nix-remove` + JSON; not pacman |
| Rollback | `omarchy rollback` | previous NixOS generation; not Snapper. Does **not** roll back `$HOME` |
| Debug | `omarchy debug` | existing wrap + pointer to the on-box `AGENTS.md` |

Theme and monitors after first login live under `$HOME`; changing the Nix option later is a no-op until those seeded files are gone. IANA timezones only.

## Installers: A then B

Both are in product (ADR-0025). **A ships first. B is the aim.** Neither ships on the current tag.

- **A — `omarchy setup` on an existing NixOS.** Stock NixOS ISO is the disk stage. Setup asks the identity questions, writes the consumer flake onto the locator (default `/etc/nixos`), copies `hardware-configuration.nix` (never regenerates it), imports `omahedron.nixosModules.default` + Home Manager from the pin, passes the Hyprland/Mesa cache on first switch, rebuilds. x86_64-linux only.
- **B — Omahedron ISO.** Boot our stick, disk + LUKS + user, land on SDDM. NixOS-shaped: UEFI, systemd-boot, generations, `nixos-install` of an Omahedron flake. Not Limine / Snapper / mkinitcpio UKI / Arch kernel packages. Honest about minutes; cache mandatory. Metal on the Latitude before it is claimed.

## On-box AGENTS.md

This repo’s [AGENTS.md](AGENTS.md) is for people changing Omahedron source. Enabled hosts also get a runtime file, `/etc/omahedron/AGENTS.md`, installed from [modules/onbox/AGENTS.md](../modules/onbox/AGENTS.md), module-owned and rebuilt with the generation, pointed to from `omarchy debug`. Its first screen says: this host is unofficial Omahedron (Omarchy desktop on NixOS); humans use `omarchy`; agents edit Nix (locator flake, `omarchy.*`, `omarchy-packages.json`, HM block; read `hardware-configuration.nix`, do not clobber it); desktop pixels come from `$OMARCHY_PATH`; theme/monitor seed rule; stub banner contract; rollback vs `$HOME`; thin desktop default.

## Sequence

1. ADR-0025 and ADR-0026 on git `DECISIONS.md`; this doc.
2. Help honesty: `omarchy --help`, group help, stubs match NixOS.
3. Installer A + identity / profile / terminal / fingerprint / autologin / pin verbs.
4. `omarchy pkg` / `rollback` / `update` routed at the existing wraps.
5. On-box `AGENTS.md` + CI check.
6. Installer B (ISO), metal on the Latitude.

## Out of scope

Host pacman / AUR / pkgs.omarchy.org. Limine / Snapper / UKI / linux-ptl as Arch packages. A second user-facing CLI brand. Nickel / Kaifile / Guix as a dependency. Hiding Nix from agents. Claiming official Omarchy or Omacom support. Tracking `quattro` on user `stable`.
