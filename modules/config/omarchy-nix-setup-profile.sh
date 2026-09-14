#!/bin/bash
# omarchy:summary=Switch desktop or workstation profile
# omarchy:args=desktop|workstation
# omarchy:examples=omarchy setup profile desktop | omarchy setup profile workstation
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"
(($# == 1)) || die "Usage: omarchy setup profile desktop | workstation"
config_apply_profile "$1"
