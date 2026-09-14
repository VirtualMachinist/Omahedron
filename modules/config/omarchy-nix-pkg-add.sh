#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"

(($# > 0)) || die "Usage: omarchy pkg add <catalog-id-or-attr> [more...]"

mapped=()
for arg in "$@"; do
  mapped+=("$(pkg_map_arg "$arg")")
done
exec "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-add" "${mapped[@]}"
