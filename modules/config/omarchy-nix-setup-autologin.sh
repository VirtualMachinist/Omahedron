#!/bin/bash
# omarchy:summary=Skip SDDM and land on the desktop (or turn autologin off)
# omarchy:args=<username>|off
# omarchy:examples=omarchy setup autologin ada | omarchy setup autologin off
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup autologin <username> | off"
config_apply_autologin "$1"
