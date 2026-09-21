# Install Hedron

Omahedron themes install into stock Omarchy. Arch Omarchy and Omarchy-Nix use the same user theme path.

## User theme path

```text
~/.config/omarchy/themes/hedron/
~/.config/omarchy/themes/hedron-light/
```

Omarchy also ships themes at `/usr/share/omarchy/themes/<name>/`. A user theme of the same name overlays that directory when you `omarchy theme set` it.

## Copy or symlink

```sh
git clone https://github.com/VirtualMachinist/Omahedron.git
cd Omahedron
mkdir -p ~/.config/omarchy/themes
ln -sfn "$PWD/themes/hedron" ~/.config/omarchy/themes/hedron
ln -sfn "$PWD/themes/hedron-light" ~/.config/omarchy/themes/hedron-light
omarchy theme set hedron
omarchy theme set hedron-light
```

A plain `cp -a` instead of `ln -sfn` is fine. Re-run `omarchy theme set` after you change files in the theme directory; Omarchy renders the active theme from a staging copy.

## Why not `omarchy theme install`

`omarchy theme install <git-url>` clones one repository into one theme directory. This repository contains `themes/hedron` and `themes/hedron-light`, so a clone of the repo root is not a theme.

On Omarchy v4.0.3, activation of a theme that came from a git clone also skips files that can run code (`*.lua`, `vscode.json`, and terminal configs). A symlink or a copy you made yourself is staged in full, so the Kanagawa and Catppuccin Latte editor stubs apply.

## Nix

The flake input is optional. It does not turn on a desktop and it does not set `allowUnfree`.

Overlay (`pkgs.omahedron-themes`):

```nix
{
  inputs.omahedron.url = "github:VirtualMachinist/Omahedron";

  outputs = { nixpkgs, omahedron, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ omahedron.overlays.default ];
      };
    in
    {
      # pkgs.omahedron-themes
      #   /share/omarchy/themes/hedron
      #   /share/omarchy/themes/hedron-light
    };
}
```

Home Manager installs the directories where Omarchy looks:

```nix
{
  imports = [ omahedron.homeManagerModules.default ];
  omahedron.themes.enable = true;
}
```

Then `omarchy theme set hedron` or `omarchy theme set hedron-light`.

`omahedron.nixosModules.default` with `omahedron.themes.enable = true` only adds that package to `environment.systemPackages`. The theme engine still reads `~/.config/omarchy/themes/`.

Build the package on its own:

```sh
nix build github:VirtualMachinist/Omahedron
```
