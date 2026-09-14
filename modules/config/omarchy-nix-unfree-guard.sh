#!/bin/bash
# omarchy-nix-unfree-guard — exit 1 when desktop profile + unfree disabled +
# catalog ids need unfree. Called from omarchy-nix-add before mutating JSON.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# > 0)) || exit 0
unfree_guard_catalog_ids "$@"
