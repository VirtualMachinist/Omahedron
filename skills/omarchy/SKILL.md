---
name: omarchy
description: >
  Use when customizing an installed omarchy-nix desktop on NixOS, including
  Hyprland, Quickshell, themes, terminals, monitors, keybindings, screenshots,
  reminders, user configuration, package selection, or Omarchy updates.
  Excludes development of the omarchy-nix or upstream Omarchy source trees.
---

# Omarchy on NixOS

Manage end-user customization of the real Omarchy Quattro desktop packaged by
omarchy-nix. Keep Omarchy's runtime UX and commands, but use NixOS-native
package and system management.

On an enabled host, read `/etc/omahedron/AGENTS.md` first (`omarchy debug`
prints the path; source: `modules/onbox/AGENTS.md` in the port repo). Do not
use this skill while developing the omarchy-nix or upstream Omarchy source
tree — follow that repository's `AGENTS.md` instead.

## Establish the Runtime

Confirm this is the NixOS port before changing anything:

```bash
test -e /run/current-system
printf 'OMARCHY_PATH=%s\n' "$OMARCHY_PATH"
omarchy version
```

Use `$OMARCHY_PATH` for all packaged Omarchy files. It points into the active
Nix store package and changes across system generations. Never assume a fixed
system path and never modify `$OMARCHY_PATH` or any `/nix/store` path.

Read packaged files freely to understand defaults and command behavior:

```bash
omarchy commands
omarchy theme set --help
sed -n '1,240p' "$(command -v omarchy-theme-set)"
sed -n '1,240p' "$OMARCHY_PATH/default/hypr/windows.lua"
```

## Ownership and Safety

Use the correct ownership layer:

- `$OMARCHY_PATH`: packaged upstream plus NixOS adaptations; read-only.
- `~/.config/`: user-owned, editable runtime configuration.
- `~/.config/omarchy/themes/`: user themes as real directories.
- `~/.config/omarchy/hooks/`: user automation.
- `~/.local/state/omarchy/current/`: generated state; change it through
  Omarchy commands.
- The consumer flake: packages, services, hardware, boot, users, and other
  system configuration.

Back up a user file before a non-trivial edit. Seek confirmation before a
reset command that replaces user configuration. Do not run a system switch,
reboot, shutdown, or destructive reset unless the request authorizes it.

Do not use `pacman`, `yay`, AUR helpers, Arch package names, or Arch repository
instructions. They are not package-management interfaces on NixOS. The human
package interface is `omarchy pkg add|drop` (NixOS wraps underneath — not
pacman).

Arch system mutators in `$OMARCHY_PATH/bin` are quarantined
(`omarchy-runtime-manifest.nix`): scripts classified `declarative-note` print
the owning NixOS option and exit 0 without changing anything, and menu entries
with no NixOS implementation are hidden. Do not work around a stub by editing
`/etc`, PAM, bootloader, or systemd units imperatively; set the option the
stub names in the consumer flake (`services.resolved`,
`services.openssh.enable`, `omarchy.fingerprint.enable`, `boot.plymouth`,
hardware features) and rebuild. The adapted scripts (`omarchy-setup-security-sshd`,
`omarchy-version`, `omarchy-update-restart`, `omarchy-debug`) keep their
upstream CLI and are safe to run.

## Privilege Escalation

For an interactive script or command run in a visible terminal, use `sudo`
for privileged work; the terminal is the right place to request a password.
On NixOS the setuid wrapper is `/run/wrappers/bin/sudo` (plain `sudo` from
the store is not setuid); Omarchy's own scripts already prefer it.

Use `pkexec` only when the caller cannot interact with a terminal or cannot
enter a password there, such as a command launched by an agent or a
graphical background process; Omarchy shows a graphical authorization
prompt. Do not replace `sudo` with `pkexec` merely because a command
changes system state, and do not wrap commands that already manage their
own elevation (`omarchy update`, `omarchy pkg add|drop`, and
`omarchy-nix-add/remove` invoke sudo themselves for the rebuild).

## System Architecture

Omarchy on NixOS is built on:

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **NixOS** | Base OS; system state is declared | the consumer flake (`/etc` is read-only, generated) |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **Omarchy shell** | Bar, launcher, notifications, OSDs (one Quickshell process) | `~/.config/omarchy/shell.json` |
| **Alacritty/Foot/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **Omarchy OSD** | On-screen display | Quickshell plugin |

## Find the Consumer Flake

All NixOS-specific Omarchy commands (update, add, remove, pkg-present, and
the search → add chain) share ONE resolver. Resolution order:

1. `$OMARCHY_NIX_FLAKE`, accepted in two equivalent forms: a directory
   containing `flake.nix`, or the path to the `flake.nix` file itself
   (named exactly `flake.nix`),
2. `/etc/nixos`, when it provides `nixosConfigurations."$(hostname)"`.

The `/etc/nixos` candidate is skipped only when its
`nixosConfigurations` evaluate cleanly but have no entry for this host
(library clones). An evaluation failure keeps the candidate instead of
silently skipping it. Home-directory scavenger paths (`~/omarchy-nix`,
`~/Projects/omarchy-nix`, `~/Omahedron`) are not supported locators.

The resolved directory is canonicalized (symlinks, `.`, trailing slashes).
An explicit `OMARCHY_NIX_FLAKE` that is invalid (missing, not a flake
directory, not a `flake.nix` file) fails closed with diagnostics: no
command ever falls back to another checkout, which could otherwise mutate
or rebuild the wrong flake.

Set `OMARCHY_NIX_FLAKE` when the configuration lives elsewhere. Treat the
consumer flake as user/system configuration, not as the omarchy-nix source
repository.

## Human vs agent

On-box contract: `/etc/omahedron/AGENTS.md` (see **Human vs agent** there).

| Who | Interface | Does |
| --- | --- | --- |
| **Human** | `omarchy setup`, `omarchy pkg add\|drop`, menus, `omarchy update` | Drives the desktop without opening `flake.nix` |
| **Agent** | Consumer flake, `omarchy.*`, `omarchy-packages.json`, `$OMARCHY_PATH` | Edits Nix; troubleshoots generations and stubs |

`omarchy setup` is the install destination: it writes the consumer flake onto
the G0 locator (default `/etc/nixos`), copies `hardware-configuration.nix`
(never regenerates it), asks the Ada questions (name, username, password,
hostname, IANA timezone, theme, terminal, profile, scale, fingerprint,
autologin — prompt copy in `setup-prompts.json` beside this skill), and
rebuilds with the Hyprland/Mesa cache on first apply. The human never opens
a `.nix` file. `omarchy pkg add|drop` is the package destination: it routes
at `omarchy-nix-add` / `omarchy-nix-remove`, updates
`<flake>/omarchy-packages.json`, and rebuilds — not pacman.

Some legacy `omarchy-pkg-pacman-*` entrypoints and narrow Arch-only setup
subcommands may still be declarative-note stubs. Prefer the configuration verbs
below or the named `omarchy.*` option the stub prints.

## Configuration verbs (NixOS)

Help copy for these routes lives in `verb-help.json` beside this skill
(`$OMARCHY_PATH/default/verbs/help.json`). Each verb writes `omarchy.*` (or the
omahedron flake input for pin/channel) in the consumer flake and rebuilds. The
human never opens a `.nix` file.

| Intent | Command | Option |
| --- | --- | --- |
| Full name | `omarchy setup name <name>` | `omarchy.full_name` |
| Email | `omarchy setup email <addr>` | `omarchy.email_address` |
| Timezone | `omarchy setup timezone <iana>` | `omarchy.timezone` |
| Profile | `omarchy setup profile desktop\|workstation` | `omarchy.profile` |
| Unfree | `omarchy setup unfree on\|off` | `omarchy.unfree.enable` |
| Terminal | `omarchy default terminal [name]` | `omarchy.terminal` (live + persisted) |
| Fingerprint | `omarchy setup fingerprint on\|off` | `omarchy.fingerprint.enable`; then `fprintd-enroll` |
| Autologin | `omarchy setup autologin <user>\|off` | `omarchy.autologin.user` |
| Pin | `omarchy pin [omahedron-X.Y.Z]` | `inputs.omahedron` tag |
| Channel | `omarchy channel set <tag>` | same as pin |

On the desktop profile, `omarchy pkg add` for an unfree catalog entry fails
with guidance to run `omarchy setup unfree on` first.

## Package and system verbs (NixOS)

| Intent | Command | Notes |
| --- | --- | --- |
| Add software | `omarchy pkg add <name…>` | Catalog ID, menu Arch name, or nixpkgs attr → `omarchy-packages.json` + rebuild |
| Remove software | `omarchy pkg drop <name…>` | Routes at `omarchy-nix-remove` |
| Search and add | `omarchy pkg install` | Interactive nixpkgs picker (`omarchy-nix-search`) |
| Remove (menu path) | `omarchy pkg remove [name…]` | Interactive multi-select when no names |
| Update | `omarchy update` | Prints pins first, then flake update + rebuild |
| Pin snapshot | `omarchy update pins` | Omahedron pin, `omarchy-src` tag, newest stable, channel |
| Channel | `omarchy version channel` | Channel + state from the shipped pin |
| Rollback | `omarchy rollback [--list]` | **Previous** generation only — **not** Snapper; **does not** roll back `$HOME` |

`omarchy pkg aur *` and legacy `omarchy-pkg-pacman-*` / `omarchy-pkg-aur-*`
stay **stubs** on NixOS (no AUR, no pacman happy path). Use `omarchy pkg
add|drop|install|remove` or the Install / Remove menus.

After a bad update, `omarchy rollback` returns the previous system generation;
your `~/.config` files stay as you left them. Older generations: `omarchy
rollback --list` or the systemd-boot menu at boot.

## Command Discovery

Prefer the stable `omarchy <group> <action>` interface:

```bash
omarchy commands
omarchy commands --json
omarchy --help
omarchy theme --help
omarchy refresh --help
omarchy restart --help
```

Common runtime groups:

| Group | Purpose | Example |
| --- | --- | --- |
| `theme` | Theme and background | `omarchy theme set nord` |
| `refresh` | Restore packaged config | `omarchy refresh shell` |
| `restart` | Restart a component | `omarchy restart shell` |
| `toggle` | Toggle a desktop feature | `omarchy toggle nightlight` |
| `bar` | Bar layout and widgets | `omarchy bar --help` |
| `plugin` | User-owned shell plugins | `omarchy plugin --help` |
| `hook` | User automation | `omarchy hook --help` |
| `launch` | Launch apps (user-safe) | `omarchy launch browser` |
| `capture` | Screenshots and recording | `omarchy capture --help` |
| `reminder` | Desktop reminders | `omarchy reminder --help` |
| `install` | Install menus; catalog entries route through `pkg` | `omarchy install webapp` |
| `pkg` | Add or remove packages (NixOS, not pacman) | `omarchy pkg add install.browser.firefox` |
| `setup` | Install or reconfigure Omahedron (wizard + identity/profile verbs) | `omarchy setup` |
| `update` | Update flake inputs and rebuild | `omarchy update` |

Command discovery lists commands, not applicability: some discovered
commands are `declarative-note` stubs that print the owning NixOS option
and change nothing (see Ownership and Safety), and menu entries with no
NixOS implementation are hidden. Legacy `omarchy-pkg-pacman-*` and some
narrow `omarchy setup …` subcommands may still be stubs — use the
top-level `omarchy setup` and `omarchy pkg add|drop` verbs, or the named
`omarchy.*` option.

Humans add and remove packages with `omarchy pkg`:

```bash
omarchy pkg add install.browser.firefox
omarchy pkg drop install.browser.firefox
omarchy pkg add firefox mc          # raw nixpkgs attributes also work
```

These route at `omarchy-nix-add` / `omarchy-nix-remove`, update
`omarchy-packages.json` beside the consumer flake, and rebuild. For an
interactive search, use **Install → Package** in the launcher or
`omarchy-nix-search`. Agents may call `omarchy-nix-add` /
`omarchy-nix-remove` directly when scripting. If the consumer manages
packages in Nix by hand, edit `omarchy-packages.json` or the flake and
rebuild.

Add/remove operations are transactional: a per-file lock serializes them,
the JSON is written atomically, a failed rebuild rolls back only that
operation's own write, and every operation leaves an audit log under
`~/.local/state/omarchy/nix-add/` (or `$XDG_STATE_HOME/omarchy/nix-add/`);
check there first when a menu install disappears with its floating
terminal. Multiple IDs in one call mean one transaction and one rebuild.

`omarchy update` preserves the upstream update UX but uses `nix flake update`
and `nixos-rebuild` internally. Useful controls:

```bash
OMARCHY_NIX_FLAKE=/path/to/config omarchy update
OMARCHY_NIX_REBUILD_CMD=build omarchy update
OMARCHY_NIX_SKIP_FLAKE_UPDATE=1 omarchy update
OMARCHY_NIX_UPDATE_DRY_RUN=1 omarchy update
```

Review a dry run or `build` before a risky deployment. The full
update wrapper can still run Omarchy migrations and hooks; a dry-run variable
only suppresses the Nix update/rebuild core.

## User Configuration

### Hyprland

User overrides live in:

```text
~/.config/hypr/
├── hyprland.lua
├── bindings.lua
├── monitors.lua
├── input.lua
├── looknfeel.lua
├── autostart.lua
└── hyprsunset.conf
```

After any change, validate:

```bash
hyprctl reload
hyprctl configerrors
```

Resolve every reported error before declaring success.

Before rebinding a key, inspect current bindings with
`omarchy menu keybindings --print`. If the key already exists, call
`hl.unbind(...)` before the new `o.bind(...)` and tell the user what it
previously did.

Window-rule syntax changes frequently. Check the documentation for the
installed Hyprland version before writing rules. Prefer Omarchy's
`o.window(match, rules)` helper and inspect examples in
`$OMARCHY_PATH/default/hypr/windows.lua`.

### Omarchy Shell

The bar, launcher, notifications, OSDs, and panels share one Quickshell
process.

```text
~/.config/omarchy/shell.json
~/.config/omarchy/plugins/<plugin-id>/
$OMARCHY_PATH/config/omarchy/shell.json
```

The shell config hot-reloads. Clone a built-in plugin before modifying it:

```bash
omarchy plugin clone omarchy.workspaces
# Edit ~/.config/omarchy/plugins/local.workspaces/; saved changes reload automatically.
```

Never edit `$OMARCHY_PATH/shell/plugins/`.

### Themes

Create custom themes under `~/.config/omarchy/themes/<name>/`. Copy a stock
theme from `$OMARCHY_PATH/themes/<name>/` as a starting point, then apply it:

```bash
omarchy theme list
omarchy theme current
omarchy theme set <name>
omarchy theme bg next
omarchy theme install <git-url>   # installs into ~/.config/omarchy/themes
```

Do not modify a stock theme in the Nix store.

### Terminals

User terminal configs live at:

```text
~/.config/alacritty/alacritty.toml
~/.config/foot/foot.ini
~/.config/kitty/kitty.conf
~/.config/ghostty/config
```

Run `omarchy restart terminal` after changing the active terminal config.

### Other Configs

| App | Location |
| --- | --- |
| btop | `~/.config/btop/btop.conf` |
| fastfetch | `~/.config/fastfetch/config.jsonc` (no system default is installed on NixOS; the user file is the only config) |
| lazygit | `~/.config/lazygit/config.yml` |
| starship | `~/.config/starship.toml` |
| git | `~/.config/git/config` (user name/email are written by first-run from `omarchy.full_name` / `omarchy.email_address`; change them in the consumer flake, not by hand) |

### Hooks

Install independent scripts under an event's `.d` directory with:

```bash
omarchy hook install <event> <script>
```

Common events include `battery-low`, `font-set`, `post-boot`, `post-update`,
and `theme-set`. The inherited `pre-refresh-pacman` hook is Arch-specific and
does not run the NixOS update core.

## Common Workflows

For a keybinding:

1. Inspect current bindings.
2. Back up `~/.config/hypr/bindings.lua`.
3. Unbind an existing chord if necessary.
4. Add the Lua binding.
5. Reload and check `hyprctl configerrors`.

For monitors:

1. Run `hyprctl monitors all`.
2. Edit `~/.config/hypr/monitors.lua` using `hl.monitor({ ... })`.
3. Reload and verify every active output.

For fonts:

```bash
omarchy font list               # Available fonts
omarchy font current            # Current font
omarchy font set <name>         # Change font (fires the font-set hook)
```

For system power/session actions (user-safe wrappers around
loginctl/systemctl; they do not edit any declarative config):

```bash
omarchy system lock             # Lock screen
omarchy system shutdown         # Shutdown
omarchy system reboot           # Reboot
```

Do not run shutdown/reboot from an agent session unless the request
explicitly authorizes it (see Ownership and Safety).

For a package:

1. Prefer `omarchy pkg add <catalog-id>` (or `omarchy-nix-search`
   interactively, which batches into one `pkg add` transaction).
2. Use a verified catalog ID or nixpkgs attribute; never pacman or AUR.
3. Verify the rebuild and the resulting command or desktop entry.
4. Use `omarchy pkg drop <id>` for items in `omarchy-packages.json`.

For a reset, request confirmation first, then use the narrowest command:

```bash
omarchy refresh config hypr/bindings.lua
omarchy refresh shell
omarchy refresh hyprland
```

For troubleshooting:

```bash
omarchy debug --no-sudo --print
omarchy commands
hyprctl configerrors
systemctl --user --failed
```

Always use `--no-sudo --print` with `omarchy debug` in an agent session.

`omarchy reinstall` (upstream's nuclear config-reset option) only chains two
steps that are both stubs on NixOS (`reinstall-pkgs` and the declarative-note
`reinstall-configs`) and then offers a reboot; it resets nothing. To re-seed
a user config, delete the file
under `~/.config/` and rebuild (`home-manager switch` or
`nixos-rebuild switch`); the seed-if-absent activation copies the packaged
default again. To restore one file without a rebuild, use
`omarchy refresh config <path-relative-to-~/.config>` (creates a timestamped
backup first).

For reminders:

```bash
omarchy reminder 15 "Pickup Jack"
omarchy reminder show
omarchy reminder clear
```

## Decision Framework

1. If it is a stock runtime action, use the documented `omarchy` command.
2. If it is user customization, edit `~/.config` or a user theme/plugin/hook.
3. If a human installs or removes software, use `omarchy pkg add|drop` (or the
   Install/Remove menus). Agents edit `omarchy-packages.json` or `omarchy.*`
   in the consumer flake.
4. If it changes services, users, boot, hardware, or policy, change the
   consumer flake and follow its deployment rules.
5. If it changes packaged Omarchy or omarchy-nix itself, stop using this skill
   and follow the source repository instructions.

Verify observable behavior after every change; a successful command alone is
not proof that the desktop behavior is correct.

## Out of Scope

This skill intentionally does not cover source development. Do not use it
for:

- Editing anything under `$OMARCHY_PATH` or any other `/nix/store` path
  (impossible anyway, since the store is read-only; the change belongs in the
  omarchy-nix repository).
- Developing omarchy-nix or upstream Omarchy: migrations, packaging, the
  NixOS/Home-Manager modules, or upstream's `omarchy dev ...` workflows.
  Follow the repository's `AGENTS.md` instead.
- Arch package management: `pacman`, `yay`, AUR helpers, Arch package
  names. There is no AUR on NixOS.
- Nix eval, rebuild forensics, flake inputs, pins, and COMPAT stubs:
  sibling skills `nix-rebuild`, `nix-flake`, `nix-module`,
  `nix-forensics`, `omahedron-compat`, `omahedron-pins`.

## Example Requests

- "Change my theme to catppuccin" → `omarchy theme set catppuccin`
- "Add a keybinding for Super+E to open the file manager" → check existing
  bindings first, `hl.unbind` if needed, then `o.bind` in
  `~/.config/hypr/bindings.lua`
- "Configure my external monitor" → edit `~/.config/hypr/monitors.lua`,
  then `hyprctl reload` + `hyprctl configerrors`
- "Make the window gaps smaller" → edit `~/.config/hypr/looknfeel.lua`
- "Set up night light at sunset" → `omarchy toggle nightlight` or edit
  `~/.config/hypr/hyprsunset.conf`
- "Change the UI font" → `omarchy font list`, then `omarchy font set <name>`
- "Install Firefox" → `omarchy pkg add install.browser.firefox` (or
  `omarchy-nix-search` interactively)
- "Install a dev database" → no catalog entry exists for databases/docker:
  enable them in the consumer flake (e.g. `virtualisation.docker.enable =
  true;`) and rebuild; a direct `omarchy install ...` may be a
  declarative-note stub
- "Set a reminder to pick up Jack in 15 minutes" →
  `omarchy reminder 15 "Pickup Jack"`
- "Run a script every time I change themes" →
  `omarchy hook install theme-set <script>`
- "Change how workspace labels are rendered" →
  `omarchy plugin clone omarchy.workspaces`, then edit the clone (saved
  changes reload automatically)
- "Lock after ten minutes" → set `idle.lock` to `600` in
  `~/.config/omarchy/shell.json`
- "Reset the shell/bar to defaults" → ask for confirmation, then
  `omarchy refresh shell`
- "Set up Omahedron on this NixOS box" → `omarchy setup` (writes the
  consumer flake; human never required to open Nix)
- "Enable fingerprint unlock" → `omarchy setup fingerprint on`, then
  `fprintd-enroll` after rebuild
- "Allow Obsidian / unfree installs" → `omarchy setup unfree on`
- "Pin Omahedron to a release" → `omarchy pin omahedron-4.0.2`
- "Change my default terminal to ghostty" → `omarchy default terminal ghostty`
- "Skip the login screen on LUKS" → `omarchy setup autologin ada`
