#!/bin/bash
# omarchy:summary=Set your full name in the flake (git and shell identity)
# omarchy:args=<full-name>
# omarchy:examples=omarchy setup name "Ada Lovelace"
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup name <full-name>"
[[ $1 != *$'\n'* && $1 != *$'\r'* ]] || die "Invalid full name."
config_apply_string "omarchy.full_name" "$1"
