#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"

if [[ ${1:-} == --list ]]; then
  if [[ ${OMARCHY_NIX_UPDATE_DRY_RUN:-} == 1 ]]; then
    echo "DRY-RUN: sudo nixos-rebuild list-generations"
    exit 0
  fi
  exec sudo nixos-rebuild list-generations
fi

echo "Rollback switches to the previous NixOS system generation only. Files under \$HOME (themes, configs, and omarchy-packages.json edits already applied) are not rewound; use the boot menu (systemd-boot generations) to pick an older generation if this generation will not boot." >&2

if [[ ${OMARCHY_NIX_UPDATE_DRY_RUN:-} == 1 ]]; then
  echo "DRY-RUN: sudo nixos-rebuild switch --rollback"
  exit 0
fi

log "Rolling back to the previous NixOS generation..."
if sudo nixos-rebuild switch --rollback; then
  if [[ -f $HELP_FILE ]]; then
    msg=$(jq -r '.verbs.rollback.onSuccess.default // empty' "$HELP_FILE")
    [[ -n $msg ]] && log "$msg"
  fi
else
  die "nixos-rebuild switch --rollback failed."
fi
