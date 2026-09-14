#!/bin/bash
# omarchy:summary=Set your email in the flake (git identity)
# omarchy:args=<address>
# omarchy:examples=omarchy setup email ada@example.com
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup email <address>"
config_apply_string "omarchy.email_address" "$1"
