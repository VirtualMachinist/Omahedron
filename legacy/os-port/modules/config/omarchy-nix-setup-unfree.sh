#!/bin/bash
# omarchy:summary=Allow unfree packages on the desktop profile
# omarchy:args=on|off
# omarchy:examples=omarchy setup unfree on | omarchy setup unfree off
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup unfree on | off"
config_apply_unfree "$1"
