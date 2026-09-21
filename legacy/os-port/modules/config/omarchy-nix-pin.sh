#!/bin/bash
# omarchy:summary=Pin or show the Omahedron flake input tag
# omarchy:args=[omahedron-X.Y.Z|main]
# omarchy:examples=omarchy pin | omarchy pin omahedron-4.0.2
# omarchy:requires-sudo=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"

if (($# == 0)); then
  config_show_pin
  exit 0
fi

(($# == 1)) || die "Usage: omarchy pin [<tag>|main]"
config_set_pin "$1"
