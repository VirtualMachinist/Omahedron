#!/bin/bash
# omarchy:summary=Print Omahedron pin, omarchy-src, newest stable, and channel state
# omarchy:hidden=true
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-configlib"

print_pin_line() {
  local flake_dir rc=0 lock node ref rev
  flake_dir=$(resolve_flake_dir) || rc=$?
  if ((rc != 0)); then
    echo "pin: no consumer flake"
    return 0
  fi
  lock="$flake_dir/flake.lock"
  if [[ ! -f $lock ]]; then
    echo "pin: unlocked (github:VirtualMachinist/Omahedron)"
    return 0
  fi
  node=$(jq -r '.nodes.root.inputs.omahedron // empty' "$lock" 2>/dev/null || true)
  [[ -n $node && $node != null ]] || node=omahedron
  ref=$(jq -r --arg n "$node" '.nodes[$n].locked.ref // empty' "$lock" 2>/dev/null || true)
  rev=$(jq -r --arg n "$node" '.nodes[$n].locked.rev // empty' "$lock" 2>/dev/null || true)
  if [[ -n $ref && $ref != null ]]; then
    echo "pin: $ref"
  elif [[ -n $rev && $rev != null ]]; then
    echo "pin: ${rev:0:7}"
  else
    echo "pin: unlocked (github:VirtualMachinist/Omahedron)"
  fi
}

print_omarchy_src_line() {
  local manifest tag rev
  manifest=$(pin_manifest_path) || {
    echo "omarchy-src: unknown (unknown)"
    return 0
  }
  tag=$(jq -r '.omarchy_tag // "unknown"' "$manifest")
  rev=$(jq -r '.omarchy_rev // ""' "$manifest")
  if [[ -n $rev ]]; then
    echo "omarchy-src: $tag (${rev:0:7})"
  else
    echo "omarchy-src: $tag (unknown)"
  fi
}

print_newest_stable_line() {
  local tag
  if [[ ${OMARCHY_NIX_OFFLINE:-} == 1 ]]; then
    echo "newest-stable: unknown (offline)"
    return 0
  fi
  tag=$(
    curl -fsSL --max-time 5 https://api.github.com/repos/basecamp/omarchy/releases/latest 2>/dev/null |
      jq -r '.tag_name // empty' 2>/dev/null || true
  )
  if [[ -n $tag ]]; then
    echo "newest-stable: $tag"
  else
    echo "newest-stable: unknown (offline)"
  fi
}

print_channel_line() {
  local manifest channel state sfp
  manifest=$(pin_manifest_path) || {
    echo "channel: unknown state=unknown security-fast-path=no"
    return 0
  }
  channel=$(jq -r '.channel // "unknown"' "$manifest")
  state=$(jq -r '.state // "unknown"' "$manifest")
  if jq -e '.security_fast_path == true' "$manifest" >/dev/null 2>&1; then
    sfp=yes
  else
    sfp=no
  fi
  echo "channel: $channel state=$state security-fast-path=$sfp"
}

print_pin_line
print_omarchy_src_line
print_newest_stable_line
print_channel_line
exit 0
