#!/bin/bash
# omarchy:summary=Persist the default terminal in the consumer flake
# omarchy:args=foot|ghostty|alacritty|kitty
# omarchy:examples=omarchy setup terminal ghostty
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup terminal <foot|ghostty|alacritty|kitty>"
config_apply_terminal "$1"
