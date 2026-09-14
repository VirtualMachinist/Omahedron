#!/bin/bash
set -euo pipefail
exec "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-search" "$@"
