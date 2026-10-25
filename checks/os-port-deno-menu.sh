#!/usr/bin/env bash
# Check a built os-port omarchy package:
#   - every hiddenMenuIds key is absent from the installed menu
#   - packaged scripts do not reference deno@latest or mise/installs/deno
# Usage: checks/os-port-deno-menu.sh <omarchy-package-output>
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
pkg="${1:?omarchy package output required}"
menu="$pkg/share/omarchy/default/omarchy/omarchy-menu.jsonc"
bin="$pkg/share/omarchy/bin"
manifest="$root/legacy/os-port/pkgs/omarchy-runtime-manifest.nix"
hider="$root/legacy/os-port/pkgs/hide-menu-entries.py"

if [[ ! -f "$menu" ]]; then
  echo "missing built menu: $menu" >&2
  exit 1
fi
if [[ ! -d "$bin" ]]; then
  echo "missing packaged scripts: $bin" >&2
  exit 1
fi

mapfile -t ids < <(
  nix eval --json --file "$manifest" --apply 'm: m.hiddenMenuIds' |
    python3 -c 'import json,sys; print("\n".join(json.load(sys.stdin)))'
)
if [[ ${#ids[@]} -eq 0 ]]; then
  echo "hiddenMenuIds is empty" >&2
  exit 1
fi

python3 "$hider" check "$menu" "${ids[@]}"

if grep -R -n -F -e 'deno@latest' -e 'mise/installs/deno' "$bin"; then
  echo "packaged scripts still reference a Deno install" >&2
  exit 1
fi
