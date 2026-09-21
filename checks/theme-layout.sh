#!/usr/bin/env bash
# Confirm themes/hedron and themes/hedron-light match a stock Omarchy theme
# directory (v4.0.3 shape) and that the Hedron stubs stay on this palette.
set -euo pipefail

root="${1:-}"
if [[ -z "$root" ]]; then
  root="$(cd "$(dirname "$0")/.." && pwd)"
fi

need_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "missing file: $path" >&2
    exit 1
  fi
}

need_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    echo "missing directory: $path" >&2
    exit 1
  fi
}

accent_of() {
  local colors="$1"
  local line hex
  line="$(grep -E '^accent = "#[0-9A-Fa-f]{6}"' "$colors" | head -n 1)"
  hex="$(sed -E 's/^accent = "#([0-9A-Fa-f]{6})".*/\1/' <<<"$line")"
  if [[ ! "$hex" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    echo "no accent hex in $colors" >&2
    exit 1
  fi
  printf '%s\n' "$hex"
}

color_of() {
  local colors="$1" key="$2"
  local line hex
  line="$(grep -E "^${key} = \"#[0-9A-Fa-f]{6}\"" "$colors" | head -n 1)"
  hex="$(sed -E "s/^${key} = \"#([0-9A-Fa-f]{6})\".*/\1/" <<<"$line")"
  if [[ ! "$hex" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    echo "no ${key} hex in $colors" >&2
    exit 1
  fi
  printf '%s\n' "$hex"
}

check_theme() {
  local name="$1"
  local dir="$root/themes/$name"
  local colors accent fg keyboard lock
  need_dir "$dir"
  need_dir "$dir/backgrounds"
  for f in colors.toml icons.theme keyboard.rgb neovim.lua preview.png \
    preview-unlock.png unlock.png shell.lock.toml vscode.json; do
    need_file "$dir/$f"
  done

  colors="$dir/colors.toml"
  accent="$(accent_of "$colors")"
  fg="$(color_of "$colors" foreground)"
  keyboard="$(tr -d '[:space:]' <"$dir/keyboard.rgb")"
  if [[ "$keyboard" != "$accent" ]]; then
    echo "$name keyboard.rgb is '$keyboard', accent is '$accent'" >&2
    exit 1
  fi

  lock="$dir/shell.lock.toml"
  if ! grep -Fq "#${fg}" "$lock"; then
    echo "$name shell.lock.toml does not use foreground #${fg}" >&2
    exit 1
  fi
  if ! grep -Fq "#${accent}" "$lock"; then
    echo "$name shell.lock.toml does not use accent #${accent}" >&2
    exit 1
  fi

  if ! grep -Fq 'LazyVim/LazyVim' "$dir/neovim.lua"; then
    echo "$name neovim.lua is not a LazyVim colorscheme stub" >&2
    exit 1
  fi

  local icons
  icons="$(tr -d '[:space:]' <"$dir/icons.theme")"
  if [[ "$icons" != "Yaru-blue" ]]; then
    echo "$name icons.theme is '$icons', expected Yaru-blue" >&2
    exit 1
  fi
}

check_theme hedron
check_theme hedron-light

if [[ -e "$root/themes/hedron/light.mode" ]]; then
  echo "hedron must not carry light.mode" >&2
  exit 1
fi
need_file "$root/themes/hedron-light/light.mode"
need_file "$root/themes/hedron/backgrounds/hedron-platonic-altar.jpeg"
need_file "$root/themes/hedron-light/backgrounds/hedron-platonic-altar-light.jpeg"

if ! grep -Fq '"extension": "qufiwefefwoyn.kanagawa"' "$root/themes/hedron/vscode.json"; then
  echo "hedron vscode.json must use the published Kanagawa extension id" >&2
  exit 1
fi
if ! grep -Fq '"name": "Kanagawa"' "$root/themes/hedron/vscode.json"; then
  echo "hedron vscode.json theme name must be Kanagawa" >&2
  exit 1
fi
if ! grep -Fq '"extension": "catppuccin.catppuccin-vsc"' "$root/themes/hedron-light/vscode.json"; then
  echo "hedron-light vscode.json must use the published Catppuccin extension id" >&2
  exit 1
fi
if ! grep -Fq '"name": "Catppuccin Latte"' "$root/themes/hedron-light/vscode.json"; then
  echo "hedron-light vscode.json theme name must be Catppuccin Latte" >&2
  exit 1
fi

if ! grep -Fq 'colorscheme = "kanagawa"' "$root/themes/hedron/neovim.lua"; then
  echo "hedron neovim.lua must select kanagawa" >&2
  exit 1
fi
if ! grep -Fq 'colorscheme = "catppuccin-latte"' "$root/themes/hedron-light/neovim.lua"; then
  echo "hedron-light neovim.lua must select catppuccin-latte" >&2
  exit 1
fi

if ! grep -Fq 'omarchy theme set hedron' "$root/README.md"; then
  echo "README must document: omarchy theme set hedron" >&2
  exit 1
fi
if ! grep -Fq 'omarchy theme set hedron-light' "$root/README.md"; then
  echo "README must document: omarchy theme set hedron-light" >&2
  exit 1
fi
if ! grep -Fq '~/.config/omarchy/themes/' "$root/README.md"; then
  echo "README must document ~/.config/omarchy/themes/" >&2
  exit 1
fi
if grep -Fq 'desktop running on NixOS' "$root/README.md"; then
  echo "README still pitches an Omarchy desktop running on NixOS" >&2
  exit 1
fi

echo "theme layout ok"
