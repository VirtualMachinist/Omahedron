#!/bin/bash
# omarchy:summary=Enable or disable fingerprint unlock for the lock screen
# omarchy:args=on|off
# omarchy:examples=omarchy setup fingerprint on | omarchy setup fingerprint off
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup fingerprint on | off"
config_apply_fingerprint "$1"
