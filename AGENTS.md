# AGENTS.md

Operating manual for this repository after ADR-0027.

Omahedron is a **theme and plugin pack for stock Omarchy**. Themes are the product. The NixOS desktop port is archived.

## Source of truth

| Domain | Winner | Artifact |
|---|---|---|
| Theme pixels and files | `themes/` | `themes/hedron`, `themes/hedron-light` |
| Install story | README | [README.md](README.md), [docs/install.md](docs/install.md) |
| Optional Nix install | Root flake | [flake.nix](flake.nix), [nix/](nix/) |
| Decisions | An ADR | [DECISIONS.md](DECISIONS.md) |
| Retired desktop port | The archive | [legacy/os-port/](legacy/os-port/) |

Do not reopen an accepted ADR. New facts go in a new ADR.

## What to change

- Theme work lands in `themes/hedron` or `themes/hedron-light`, with [checks/theme-layout.sh](checks/theme-layout.sh) still passing.
- Install, overlay, and module work lands in `flake.nix` and `nix/`. Keep it thin. `omahedron.themes.enable` installs themes. It does not enable a desktop.
- Docs a stranger sees: [README.md](README.md), [SPEC.md](SPEC.md), [docs/install.md](docs/install.md).

## What to leave alone

- `legacy/os-port/` is the retired NixOS port (modules, vendored-Omarchy flake, ledgers). Do not delete it. Do not point root CI at it. Do not pitch it as the product. Its manual is [legacy/os-port/AGENTS.md](legacy/os-port/AGENTS.md), marked archived.
- Do not set `allowUnfree`, Steam, or other unfree defaults.
- Do not invent affiliation with Basecamp, 37signals, or Omacom.
- Do not use the brand Omarchanite.
- Do not invent a Neovim colorscheme or a VS Code marketplace id. Editor stubs name schemes that already exist.

## Checks

```sh
bash checks/theme-layout.sh
nix flake check
```

Root CI runs those. It does not build the archived desktop port.
