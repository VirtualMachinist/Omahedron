# omarchy-nix-configlib — shared helpers for G3 config verbs (patch
# configuration.nix / flake.nix on the G0 locator, then nixos-rebuild).
# Sourced by omarchy-nix-* scripts in modules/config/; not executed directly.

HELP_FILE="@@CONFIG_HELP_FILE@@"
CATALOG_FILE="@@CONFIG_CATALOG_FILE@@"
CONFIG_PIN_FILE="@@CONFIG_PIN_FILE@@"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/nix-config"

_pkglib="$(dirname "${BASH_SOURCE[0]}")/omarchy-nix-pkglib"
[[ -f $_pkglib ]] && source "$_pkglib"

log() { echo -e "\e[32m$*\e[0m"; }
warn() { echo -e "\e[33m$*\e[0m" >&2; }

verb_err() {
  local key="$1" fallback="${2:-}"
  local msg
  if [[ -f $HELP_FILE ]]; then
    msg=$(jq -r --arg k "$key" '.shared.errors[$k] // empty' "$HELP_FILE")
  fi
  [[ -n $msg ]] || msg="$fallback"
  die "$msg"
}

read_file_as_user() {
  local f="$1"
  if [[ -r $f ]]; then cat "$f"
  else sudo cat "$f"
  fi
}

write_file_as_user() {
  local f="$1" content="$2"
  local tmp="${f}.tmp.$$"
  if [[ -w $(dirname "$f") ]]; then
    printf '%s\n' "$content" >"$tmp" && mv "$tmp" "$f"
  else
    printf '%s\n' "$content" | sudo tee "$tmp" >/dev/null && sudo mv "$tmp" "$f"
  fi
}

nix_quote_string() {
  local s="$1" q
  q=$(jq -Rn --arg s "$s" '$s')
  q=${q//\$\{/'\\${'}
  printf '%s' "$q"
}

awk_escape_regex() {
  printf '%s' "$1" | sed 's/[.[\*^$()+?{|]/\\&/g'
}

patch_nix_option() {
  local file="$1" option="$2" nix_value="$3"
  local assignment="  ${option} = ${nix_value};"
  local eopt out
  eopt=$(awk_escape_regex "$option")
  if grep -qE "^[[:space:]]*${eopt}[[:space:]]*=" "$file"; then
    out=$(awk -v eopt="$eopt" -v asn="$assignment" '
      $0 ~ ("^[ \\t]*" eopt "[ \\t]*=") { print asn; next }
      { print }
    ' "$file")
  elif grep -qE '^[[:space:]]*omarchy\.enable = true;' "$file"; then
    out=$(awk -v asn="$assignment" '
      /^[ \t]*omarchy\.enable = true;[ \t]*$/ { print; print asn; next }
      { print }
    ' "$file")
  else
    die "could not find ${option} or omarchy.enable = true in ${file}; an agent can set it by hand"
  fi
  printf '%s' "$out"
}

patch_flake_omahedron_url() {
  local file="$1" url="$2"
  local assignment="    omahedron.url = \"${url}\";"
  local out
  if ! out=$(
    awk -v asn="$assignment" '
      BEGIN { done = 0 }
      /^[ \t]*omahedron\.url[ \t]*=/ {
        print asn
        done = 1
        next
      }
      { print }
      END { if (!done) exit 1 }
    ' "$file" 2>&1
  ); then
    die "could not find omahedron.url in ${file}; an agent can set it by hand"
  fi
  printf '%s' "$out"
}

read_config_assignment() {
  local file="$1" option="$2"
  local eopt line
  eopt=$(awk_escape_regex "$option")
  line=$(grep -E "^[[:space:]]*${eopt}[[:space:]]*=" "$file" | head -1 || true)
  [[ -n $line ]] || return 1
  sed -E 's/^[[:space:]]*[^=]+=[[:space:]]*//;s/[[:space:]]*;$//' <<<"$line"
}

config_begin() {
  flake_dir=$(resolve_flake_dir_or_die)
  config_nix="$flake_dir/configuration.nix"
  flake_nix="$flake_dir/flake.nix"
  [[ -f $config_nix ]] || die "No configuration.nix in $flake_dir — run omarchy setup first."
  [[ -f $flake_nix ]] || die "No flake.nix in $flake_dir."
  mkdir -p "$STATE_DIR"
  op_log="$STATE_DIR/$(date +%Y%m%d-%H%M%S)-$$.log"
  CONFIG_PREIMAGE=$(read_file_as_user "$config_nix")
  FLAKE_PREIMAGE=$(read_file_as_user "$flake_nix")
  {
    echo "started: $(date -Is)"
    echo "flake: $flake_dir"
    echo "pid: $$"
  } >>"$op_log"
}

config_write_config() {
  write_file_as_user "$config_nix" "$1"
}

config_write_flake() {
  write_file_as_user "$flake_nix" "$1"
}

config_apply_config_image() {
  local pre_hash post_hash
  pre_hash=$(printf '%s' "$CONFIG_PREIMAGE" | sha256sum | cut -d' ' -f1)
  post_hash=$(printf '%s' "$CONFIG_POSTIMAGE" | sha256sum | cut -d' ' -f1)
  if [[ $pre_hash == "$post_hash" ]]; then
    log "No change — already set."
    return 1
  fi
  config_write_config "$CONFIG_POSTIMAGE"
  return 0
}

config_lock_omahedron() {
  if [[ ${OMARCHY_NIX_UPDATE_DRY_RUN:-} == 1 ]]; then
    echo "DRY-RUN: nix flake lock --update-input omahedron"
    return 0
  fi
  if [[ -w $flake_dir ]]; then
    (cd "$flake_dir" && nix flake lock --update-input omahedron)
  else
    sudo bash -c "cd '$flake_dir' && nix flake lock --update-input omahedron"
  fi
}

config_rebuild() {
  if [[ ${OMARCHY_NIX_UPDATE_DRY_RUN:-} == 1 ]]; then
    echo "DRY-RUN: sudo nixos-rebuild ${OMARCHY_NIX_REBUILD_CMD:-switch} --flake $flake_dir"
    return 0
  fi
  log "Rebuilding the system (this can take a minute or two)...  (full log: $op_log)"
  if sudo nixos-rebuild "${OMARCHY_NIX_REBUILD_CMD:-switch}" --flake "$flake_dir" 2>&1 | tee -a "$op_log"; then
    echo "result: rebuild ok" >>"$op_log"
    return 0
  fi
  echo "result: rebuild failed" >>"$op_log"
  config_write_config "$CONFIG_PREIMAGE"
  [[ -n ${FLAKE_PREIMAGE:-} ]] && config_write_flake "$FLAKE_PREIMAGE"
  verb_err rebuildFailed "nixos-rebuild failed. Your flake was rolled back."
}

config_apply_options() {
  config_begin
  local tmp content
  tmp=$(mktemp)
  printf '%s' "$CONFIG_PREIMAGE" >"$tmp"
  while (($# > 0)); do
    local option="$1" nix_value="$2"
    shift 2
    content=$(patch_nix_option "$tmp" "$option" "$nix_value")
    printf '%s' "$content" >"$tmp"
    echo "set ${option} = ${nix_value} in ${config_nix}"
  done
  CONFIG_POSTIMAGE=$(cat "$tmp")
  rm -f "$tmp"
  if config_apply_config_image; then
    config_rebuild
  fi
}

config_apply_string() {
  local option="$1" value="$2"
  [[ -n $value && $value != *$'\n'* && $value != *$'\r'* ]] || die "Invalid value for $option."
  config_apply_options "$option" "$(nix_quote_string "$value")"
}

config_apply_bool() {
  local option="$1" value="$2"
  case "$value" in
  true|false) config_apply_options "$option" "$value" ;;
  *) die "Invalid boolean for $option: $value" ;;
  esac
}

valid_iana_timezone() {
  local tz="$1" zbase="${TZDIR:-/etc/zoneinfo}"
  [[ -n $tz && $tz != *$'\n'* && $tz != *$'\r'* ]] || return 1
  [[ -f "$zbase/$tz" || -f "/usr/share/zoneinfo/$tz" ]] || return 1
  if command -v timedatectl >/dev/null 2>&1; then
    timedatectl list-timezones 2>/dev/null | grep -Fxq "$tz"
  else
    return 0
  fi
}

config_apply_timezone() {
  local tz="$1"
  valid_iana_timezone "$tz" || verb_err ianaTimezone "Timezone must be a valid IANA name."
  config_apply_options \
    "omarchy.timezone" "$(nix_quote_string "$tz")" \
    "time.timeZone" "$(nix_quote_string "$tz")"
}

config_apply_profile() {
  case "$1" in
  desktop|workstation) config_apply_options "omarchy.profile" "$(nix_quote_string "$1")" ;;
  *) verb_err invalidProfile "Profile must be desktop or workstation." ;;
  esac
}

config_apply_unfree() {
  case "$1" in
  on) config_apply_bool "omarchy.unfree.enable" true ;;
  off) config_apply_bool "omarchy.unfree.enable" false ;;
  *) verb_err invalidUnfree "Use: omarchy setup unfree on | off" ;;
  esac
}

config_apply_fingerprint() {
  case "$1" in
  on)
    config_apply_bool "omarchy.fingerprint.enable" true
    if [[ ${OMARCHY_NIX_UPDATE_DRY_RUN:-} == 1 ]]; then
      echo "Fingerprint unlock is enabled. Run fprintd-enroll as your user to register a finger."
      return 0
    fi
    if command -v omarchy-hw-fingerprint >/dev/null 2>&1 && omarchy-hw-fingerprint; then
      fprintd-enroll "$USER" || true
      fprintd-verify || true
    else
      echo "No fingerprint reader detected — enroll skipped."
    fi
    ;;
  off) config_apply_bool "omarchy.fingerprint.enable" false ;;
  *) verb_err invalidFingerprint "Use: omarchy setup fingerprint on | off" ;;
  esac
}

config_apply_autologin() {
  case "$1" in
  off) config_apply_options "omarchy.autologin.user" "null" ;;
  '')
    verb_err invalidAutologin "Use: omarchy setup autologin <username> | off"
    ;;
  *)
    [[ $1 =~ ^[a-z_][a-z0-9_-]*$ ]] || verb_err invalidAutologin "Invalid username."
    config_apply_options "omarchy.autologin.user" "$(nix_quote_string "$1")"
    ;;
  esac
}

config_apply_terminal() {
  local term="$1"
  case "$term" in
  foot|ghostty|alacritty|kitty) ;;
  *) verb_err invalidTerminal "Terminal must be foot, ghostty, alacritty, or kitty." ;;
  esac
  config_apply_options "omarchy.terminal" "$(nix_quote_string "$term")"
}

read_flake_omahedron_pin() {
  local dir="$1" flake_nix url ref
  flake_nix="$dir/flake.nix"
  [[ -f $flake_nix ]] || {
    printf '%s\n' unknown
    return 0
  }
  url=$(grep -E '[[:space:]]*omahedron\.url[[:space:]]*=' "$flake_nix" | head -1 |
    sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/') || true
  [[ -n $url ]] || {
    printf '%s\n' unknown
    return 0
  }
  ref="${url##*/}"
  if [[ $url == github:VirtualMachinist/Omahedron || $ref == Omahedron ]]; then
    printf '%s (main)\n' "$url"
  else
    printf '%s\n' "$url"
  fi
}

pin_manifest_path() {
  local base="${OMARCHY_PATH:-/run/current-system/sw/share/omarchy}"
  [[ -f $base/pin.json ]] && printf '%s\n' "$base/pin.json" && return 0
  if [[ -f $CONFIG_PIN_FILE && $CONFIG_PIN_FILE != '@@CONFIG_PIN_FILE@@' ]]; then
    printf '%s\n' "$CONFIG_PIN_FILE"
    return 0
  fi
  return 1
}

pkg_map_arg() {
  local name="$1" catalog mapped
  catalog=$(catalog_path) || {
    printf '%s\n' "$name"
    return 0
  }
  if jq -e --arg id "$name" '.entries[$id]' "$catalog" >/dev/null 2>&1; then
    printf '%s\n' "$name"
    return 0
  fi
  mapped=$(jq -r --arg a "$name" '[.entries | to_entries[] | select(.value.arch == $a) | .key] | first // empty' "$catalog" 2>/dev/null || true)
  if [[ -n $mapped ]]; then
    printf '%s\n' "$mapped"
    return 0
  fi
  printf '%s\n' "$name"
}

config_show_pin() {
  config_begin
  read_flake_omahedron_pin "$flake_dir"
}

config_set_pin() {
  local ref="$1" url new_flake pre_hash post_hash
  if [[ $ref == main ]]; then
    url='github:VirtualMachinist/Omahedron'
  elif [[ $ref =~ ^omahedron-[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    url="github:VirtualMachinist/Omahedron/${ref}"
  else
    die "Usage: omarchy pin [omahedron-X.Y.Z|main]"
  fi
  config_begin
  new_flake=$(patch_flake_omahedron_url "$flake_nix" "$url")
  pre_hash=$(printf '%s' "$FLAKE_PREIMAGE" | sha256sum | cut -d' ' -f1)
  post_hash=$(printf '%s' "$new_flake" | sha256sum | cut -d' ' -f1)
  if [[ $pre_hash == "$post_hash" ]]; then
    log "Already pinned to $ref."
    return 0
  fi
  config_write_flake "$new_flake"
  echo "set omahedron.url = \"${url}\" in ${flake_nix}"
  config_lock_omahedron
  config_rebuild
}

catalog_path() {
  local base="${OMARCHY_PATH:-/run/current-system/sw/share/omarchy}"
  if [[ -f $base/nix-catalog.json ]]; then
    printf '%s\n' "$base/nix-catalog.json"
  elif [[ -f $CATALOG_FILE ]]; then
    printf '%s\n' "$CATALOG_FILE"
  else
    return 1
  fi
}

read_config_profile() {
  local v
  v=$(read_config_assignment "$config_nix" "omarchy.profile" 2>/dev/null || true)
  v=${v//\"/}
  [[ -n $v ]] || v=desktop
  printf '%s\n' "$v"
}

read_config_unfree_enabled() {
  local v
  v=$(read_config_assignment "$config_nix" "omarchy.unfree.enable" 2>/dev/null || true)
  [[ $v == true ]]
}

unfree_guard_catalog_ids() {
  local id catalog
  flake_dir=$(resolve_flake_dir_or_die)
  config_nix="$flake_dir/configuration.nix"
  catalog=$(catalog_path) || return 0
  [[ $(read_config_profile) == desktop ]] || return 0
  read_config_unfree_enabled && return 0
  for id in "$@"; do
    if jq -e --arg id "$id" '.entries[$id].unfreeNames | length > 0' "$catalog" >/dev/null 2>&1; then
      verb_err unfreePkgAddDesktop \
        "That package needs unfree software. On the desktop profile, run: omarchy setup unfree on — then try omarchy pkg add again."
    fi
    local feat
    feat=$(jq -r --arg id "$id" '.entries[$id].feature // empty' "$catalog")
    if [[ -n $feat ]] && jq -e --arg f "$feat" '.features[$f].unfreeNames | length > 0' "$catalog" >/dev/null 2>&1; then
      verb_err unfreePkgAddDesktop \
        "That package needs unfree software. On the desktop profile, run: omarchy setup unfree on — then try omarchy pkg add again."
    fi
  done
}
