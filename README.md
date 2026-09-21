<p align="center">
  <a href="https://github.com/VirtualMachinist/Omahedron">
    <img src="docs/brand/omahedron-mark-512.png" alt="Omahedron" width="220">
  </a>
</p>

<h1 align="center">Omahedron</h1>

<p align="center">
  <strong>Hedron themes for stock Omarchy.</strong><br>
  Theme pack first. Plugins when they are real.
</p>

<p align="center">
  <a href="https://github.com/VirtualMachinist/Omahedron/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/VirtualMachinist/Omahedron/ci.yml?branch=main&style=flat&colorA=0a0e1e&colorB=a96a38&label=ci" alt="CI"></a>
  <a href="https://github.com/basecamp/omarchy"><img src="https://img.shields.io/badge/Omarchy-themes-a96a38?style=flat&colorA=0a0e1e" alt="Omarchy themes"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/VirtualMachinist/Omahedron?style=flat&colorA=0a0e1e&colorB=a96a38" alt="MIT license"></a>
  <a href="https://hedronite.com"><img src="https://img.shields.io/badge/Hedronite-hedronite.com-2e5ab8?style=flat&colorA=0a0e1e" alt="Hedronite"></a>
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#themes">Themes</a> ·
  <a href="#plugins">Plugins</a> ·
  <a href="#nix">Nix</a> ·
  <a href="docs/install.md">Install guide</a> ·
  <a href="#legacy-desktop-port">Legacy port</a>
</p>

---

Omahedron is a theme pack for [Omarchy](https://omarchy.org). It ships **Hedron** and **Hedron Light**: lapis fields, copper and bronze edges, wallpapers included. It runs on stock Arch Omarchy and on Omarchy-Nix. You install the theme directories, then set them with `omarchy theme`.

Unofficial. The desktop is Omarchy's. Omahedron is maintained by [Hedronite](https://hedronite.com). It is not affiliated with Omarchy, Basecamp, 37signals, or Omacom.

## Install

Copy or symlink each theme into Omarchy's user theme directory, then set it.

```sh
git clone https://github.com/VirtualMachinist/Omahedron.git
cd Omahedron
mkdir -p ~/.config/omarchy/themes
ln -sfn "$PWD/themes/hedron" ~/.config/omarchy/themes/hedron
ln -sfn "$PWD/themes/hedron-light" ~/.config/omarchy/themes/hedron-light
omarchy theme set hedron
```

Light twin:

```sh
omarchy theme set hedron-light
```

`~/.config/omarchy/themes/<name>/` is the user theme path. Omarchy's own themes live under `/usr/share/omarchy/themes/<name>/`. A user directory with the same name overlays the system one.

Use a symlink or a plain copy. `omarchy theme install <git-url>` clones a repository into a single theme folder. This repository is a pack of two themes, so that command lands the wrong tree. On Omarchy v4.0.3 a cloned theme also drops `neovim.lua` and `vscode.json` at activation. A symlink of `themes/hedron` is applied in full, including those editor stubs.

Details and the optional Nix install: [docs/install.md](docs/install.md).

## Themes

| Directory | Set with | Mode | Wallpaper |
|---|---|---|---|
| [`themes/hedron`](themes/hedron) | `omarchy theme set hedron` | dark | `backgrounds/hedron-platonic-altar.jpeg` |
| [`themes/hedron-light`](themes/hedron-light) | `omarchy theme set hedron-light` | light (`light.mode`) | `backgrounds/hedron-platonic-altar-light.jpeg` |

Palette comes from those wallpapers. Dark accent is copper `#a96a38` on lapis `#0a0e1e`. Light accent is bronze `#7a4a32` on sky `#eef3f8`. Icons are `Yaru-blue`.

A stock Omarchy theme directory (v4.0.3) is the model. Each pack includes:

| File | Role |
|---|---|
| `colors.toml` | Palette Omarchy templates render from |
| `backgrounds/` | Wallpaper |
| `icons.theme` | Icon theme name |
| `preview.png`, `preview-unlock.png`, `unlock.png` | Theme switcher and lock art |
| `keyboard.rgb` | Accent hex, no `#` |
| `shell.lock.toml` | Lock-screen text, placeholder, and border from `colors.toml` |
| `neovim.lua` | Nearest LazyVim colorscheme (see below) |
| `vscode.json` | Nearest published VS Code theme |
| `light.mode` | Present on Hedron Light only |

Editor files are nearest published schemes. There is no Hedron-native Neovim or VS Code theme.

| | Neovim (LazyVim) | VS Code extension | Theme name |
|---|---|---|---|
| Hedron | [`rebelot/kanagawa.nvim`](https://github.com/rebelot/kanagawa.nvim) `kanagawa` | `qufiwefefwoyn.kanagawa` | Kanagawa |
| Hedron Light | [`catppuccin/nvim`](https://github.com/catppuccin/nvim) `catppuccin-latte` | `catppuccin.catppuccin-vsc` | Catppuccin Latte |

Kanagawa is the closest LazyVim scheme for the dark lapis field. Catppuccin Latte is the closest for the light sky field. Copper and bronze stay on the shell, window borders, and keyboard backlight.

## Plugins

These are the pack targets. None of them are installed by this repository yet.

| Target | What it is | Here |
|---|---|---|
| [Facet](https://github.com/Hedronite/facet) | API client for humans and agents | not packaged |
| [Geode](https://github.com/Hedronite/geode) | File custody (GDE1 vaults) | not packaged |
| [Lapis](https://github.com/Hedronite/lapis-lattice) | Vault search and RAG | not packaged |
| [Hedronos](https://github.com/Hedronite/hedronos) | Terminal workshop; pulls fullstack-lab | not packaged |
| [fullstack-lab](https://github.com/Hedronite/fullstack-lab) | Fullstack practice lab | not packaged |

When one of those ships as an Omarchy plugin, it lands in this repo with the same install story as the themes: a directory you can point stock Omarchy at, plus a flake output. Until then the flake only installs themes.

## Nix

Optional. Stock Omarchy does not need it. The flake is a thin overlay and an opt-in Home Manager module. It does not enable a desktop, and it does not set `allowUnfree`.

```nix
{
  inputs.omahedron.url = "github:VirtualMachinist/Omahedron";

  outputs = { omahedron, ... }: {
    # nixpkgs overlay: pkgs.omahedron-themes
    # -> $out/share/omarchy/themes/{hedron,hedron-light}
  };
}
```

Home Manager, still opt-in:

```nix
{
  imports = [ omahedron.homeManagerModules.default ];
  omahedron.themes.enable = true;
}
```

That symlinks the two theme directories into `~/.config/omarchy/themes/`. Then:

```sh
omarchy theme set hedron
```

`nixosModules.default` only adds the theme package to `environment.systemPackages` when `omahedron.themes.enable` is set. It is not a session, a greeter, or a Hyprland config.

```sh
nix build github:VirtualMachinist/Omahedron
# result/share/omarchy/themes/hedron
# result/share/omarchy/themes/hedron-light
```

## Legacy desktop port

Earlier revisions of this repository were a NixOS port of the Omarchy desktop (modules, a vendored Omarchy pin, `omarchy.enable`). That port is archived under [`legacy/os-port/`](legacy/os-port/). The tagged release [`omahedron-4.0.3`](https://github.com/VirtualMachinist/Omahedron/releases/tag/omahedron-4.0.3) is that port, at Omarchy v4.0.3. Root CI checks the theme pack.

## Contributing

Issues and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md), then [AGENTS.md](AGENTS.md) and [DECISIONS.md](DECISIONS.md). Theme files live in `themes/`. The archived port is not the place to add desktop features.

## Credits and license

Omahedron is maintained by [Hedronite](https://hedronite.com). Omarchy is by DHH and Basecamp. The archived Nix glue started from [zicochaos/omarchy-nix](https://github.com/zicochaos/omarchy-nix); that credit stays in [docs/CREDITS.md](docs/CREDITS.md).

MIT. See [LICENSE](LICENSE). The mark is Hedronite's; notes are in [docs/brand/](docs/brand/).
