#!/bin/bash
# omarchy:summary=Set the system timezone (IANA only)
# omarchy:args=<iana>
# omarchy:examples=omarchy setup timezone America/Chicago
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup timezone <iana>"
config_apply_timezone "$1"
