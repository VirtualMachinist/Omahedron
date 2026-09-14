#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"

manifest=$(pin_manifest_path) || {
  echo "unknown (unknown)"
  exit 0
}
channel=$(jq -r '.channel // "unknown"' "$manifest")
state=$(jq -r '.state // "unknown"' "$manifest")
echo "$channel ($state)"
exit 0
