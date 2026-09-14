#!/usr/bin/env bash
# omarchy:summary=Install Omahedron on this NixOS system (writes the consumer flake on the G0 locator)
# omarchy:args=[-y] [--force]
# omarchy:examples=omarchy setup | omarchy setup -y
# omarchy:requires-sudo=true
# omarchy-nix-setup — Installer A: write the consumer flake on the G0 locator,
# copy hardware-configuration.nix (never nixos-generate-config), prompt, rebuild.
set -euo pipefail

OMARCHY_PATH="${OMARCHY_PATH:-/run/current-system/sw/share/omarchy}"
TEMPLATE_DIR="@@SETUP_TEMPLATE_DIR@@"
PROMPTS_FILE="@@SETUP_PROMPTS_FILE@@"
OMAHEDRON_FLAKE_URL="@@SETUP_OMAHEDRON_URL@@"
HYPR_CACHE_URL="@@SETUP_HYPR_CACHE_URL@@"
HYPR_CACHE_KEY="@@SETUP_HYPR_CACHE_KEY@@"

SKIP_CONFIRM=0
FORCE=0

log() { echo -e "\e[32m$*\e[0m"; }
warn() { echo -e "\e[33m$*\e[0m" >&2; }
die() { echo -e "\e[31m$*\e[0m" >&2; exit 1; }

# NixOS setuid sudo wrapper when present.
if [[ -x /run/wrappers/bin/sudo ]]; then
  sudo() { command /run/wrappers/bin/sudo "$@"; }
fi

prompts_json() {
  if [[ -f $PROMPTS_FILE ]]; then
    cat "$PROMPTS_FILE"
  elif [[ -f "$OMARCHY_PATH/default/setup/prompts.json" ]]; then
    cat "$OMARCHY_PATH/default/setup/prompts.json"
  else
    die "Setup prompts file missing (expected $PROMPTS_FILE)."
  fi
}

prompt_err() {
  local key="$1"
  jq -r --arg k "$key" '.errors[$k] // empty' <<<"$(prompts_json)"
}

require_linux_x86_64() {
  [[ $(uname -s) == Linux ]] || die "$(prompt_err unsupportedArch)"
  [[ $(uname -m) == x86_64 ]] || die "$(prompt_err unsupportedArch)"
}

resolve_setup_target_dir() {
  local v="${OMARCHY_NIX_FLAKE:-}" d canon
  if [[ -n $v ]]; then
    if [[ -d $v ]]; then
      d=$v
    elif [[ -f $v && ${v##*/} == flake.nix ]]; then
      d=$(dirname -- "$v")
    else
      {
        echo "omarchy-nix-setup: invalid OMARCHY_NIX_FLAKE: '$v'" >&2
        echo "  expected: a directory, or the path to a flake.nix file" >&2
        echo "  refusing to fall back to another checkout" >&2
      } >&2
      die "$(prompt_err locatorNotWritable)"
    fi
    canon=$(cd -- "$d" 2>/dev/null && pwd -P) || die "$(prompt_err locatorNotWritable)"
    printf '%s\n' "$canon"
    return 0
  fi
  printf '%s\n' /etc/nixos
}

write_as_root() {
  local dest="$1" content="$2"
  if [[ -w $(dirname "$dest") ]]; then
    printf '%s' "$content" >"$dest"
  else
    printf '%s' "$content" | sudo tee "$dest" >/dev/null
  fi
}

copy_file_as_root() {
  local src="$1" dest="$2"
  if [[ -w $(dirname "$dest") ]]; then
    cp --reflink=auto -f "$src" "$dest"
  else
    sudo cp --reflink=auto -f "$src" "$dest"
  fi
}

backup_file_as_root() {
  local f="$1" bak="$1.bak-$(date +%s)"
  if [[ -w $f ]]; then mv "$f" "$bak"
  else sudo mv "$f" "$bak"
  fi
  echo "$bak"
}

hash_file() {
  local f="$1"
  if [[ -r $f ]]; then sha256sum "$f" | cut -d' ' -f1
  else sudo sha256sum "$f" | cut -d' ' -f1
  fi
}

render_template() {
  local template="$1" dest="$2"
  local content
  content=$(<"$template")
  content=${content//@HOSTNAME@/$HOSTNAME}
  content=${content//@USERNAME@/$USERNAME}
  content=${content//@FULL_NAME@/$FULL_NAME}
  content=${content//@EMAIL@/$EMAIL}
  content=${content//@TIMEZONE@/$TIMEZONE}
  content=${content//@THEME@/$THEME}
  content=${content//@TERMINAL@/$TERMINAL}
  content=${content//@PROFILE@/$PROFILE}
  content=${content//@SCALE@/$SCALE}
  content=${content//@PASSWORD_HASH@/$PASSWORD_HASH}
  content=${content//@OMAHEDRON_FLAKE_URL@/$OMAHEDRON_FLAKE_URL}
  content=${content//@FINGERPRINT_BLOCK@/$FINGERPRINT_BLOCK}
  content=${content//@AUTOLOGIN_BLOCK@/$AUTOLOGIN_BLOCK}
  write_as_root "$dest" "$content"
}

hash_password() {
  local pw="$1"
  if command -v mkpasswd >/dev/null 2>&1; then
    mkpasswd -m sha-512 "$pw"
  elif command -v openssl >/dev/null 2>&1; then
    openssl passwd -6 "$pw"
  else
    die "Need mkpasswd or openssl to hash the login password."
  fi
}

zoneinfo_path() {
  local tz="$1"
  local zdir="${TZDIR:-/etc/zoneinfo}"
  if [[ -f "$zdir/$tz" ]]; then
    printf '%s\n' "$zdir/$tz"
  elif [[ -f "/usr/share/zoneinfo/$tz" ]]; then
    printf '%s\n' "/usr/share/zoneinfo/$tz"
  else
    return 1
  fi
}

valid_iana_timezone() {
  local tz="$1"
  zoneinfo_path "$tz" >/dev/null || return 1
  if command -v timedatectl >/dev/null 2>&1; then
    timedatectl list-timezones 2>/dev/null | grep -Fxq "$tz"
  else
    return 0
  fi
}

field_pattern() {
  local field="$1" fallback="${2:-.*}"
  jq -r --arg f "$field" ".fields[\$f].validate.pattern // \"$fallback\"" <<<"$(prompts_json)"
}

field_pattern_msg() {
  local field="$1" fallback="$2"
  jq -r --arg f "$field" ".fields[\$f].validate.message // \"$fallback\"" <<<"$(prompts_json)"
}

choice_allowed() {
  local field="$1" value="$2"
  jq -e --arg f "$field" --arg v "$value" '
    .fields[$f].choices
    | if . == null then true
      else any(. == $v or (.value? == $v))
      end
  ' <<<"$(prompts_json)" >/dev/null
}

validate_answer_field() {
  local field="$1" value="$2"
  local pattern
  case "$field" in
  username)
    pattern=$(field_pattern username '^[a-z][a-z0-9_-]*$')
    [[ $value =~ $pattern ]] || die "$(field_pattern_msg username 'Invalid username.')"
    ;;
  hostname)
    pattern=$(field_pattern hostname '^[A-Za-z0-9][A-Za-z0-9.-]*$')
    [[ $value =~ $pattern ]] || die "$(field_pattern_msg hostname 'Invalid hostname.')"
    ;;
  timezone)
    valid_iana_timezone "$value" || die "$(field_pattern_msg timezone 'Invalid IANA timezone.')"
    ;;
  theme|terminal|profile|scale)
    choice_allowed "$field" "$value" || die "Invalid $field: $value"
    ;;
  full_name)
    [[ -n $value && $value != *$'\n'* && $value != *$'\r'* ]] || die "Invalid full_name."
    ;;
  esac
}

apply_answer_blocks() {
  if [[ ${FINGERPRINT:-false} == true ]]; then
    FINGERPRINT_BLOCK='  omarchy.fingerprint.enable = true;'
  else
    FINGERPRINT_BLOCK=''
  fi
  if [[ ${AUTOLOGIN:-false} == true ]]; then
    AUTOLOGIN_BLOCK="  omarchy.autologin.user = \"$USERNAME\";"
  else
    AUTOLOGIN_BLOCK=''
  fi
}

collect_answers_from_file() {
  local file="$1" raw
  [[ -f $file ]] || die "OMARCHY_SETUP_ANSWERS: no such file: $file"
  raw=$(cat "$file")
  jq -e . <<<"$raw" >/dev/null || die "OMARCHY_SETUP_ANSWERS: invalid JSON: $file"

  FULL_NAME=$(jq -r '.full_name // empty' <<<"$raw")
  USERNAME=$(jq -r '.username // empty' <<<"$raw")
  HOSTNAME=$(jq -r '.hostname // empty' <<<"$raw")
  TIMEZONE=$(jq -r '.timezone // empty' <<<"$raw")
  THEME=$(jq -r '.theme // empty' <<<"$raw")
  TERMINAL=$(jq -r '.terminal // empty' <<<"$raw")
  PROFILE=$(jq -r '.profile // empty' <<<"$raw")
  SCALE=$(jq -r '.scale // empty' <<<"$raw")
  FINGERPRINT=$(jq -r '.fingerprint // false' <<<"$raw")
  AUTOLOGIN=$(jq -r '.autologin // false' <<<"$raw")

  for req in full_name username hostname timezone theme terminal profile scale; do
    var=${req^^}
    [[ -n ${!var:-} ]] || die "OMARCHY_SETUP_ANSWERS: missing required key: $req"
  done

  if jq -e 'has("password_hash")' <<<"$raw" >/dev/null; then
    PASSWORD_HASH=$(jq -r '.password_hash' <<<"$raw")
  elif jq -e 'has("password")' <<<"$raw" >/dev/null; then
    PASSWORD_HASH=$(hash_password "$(jq -r '.password' <<<"$raw")")
  else
    die "OMARCHY_SETUP_ANSWERS: need password_hash or password"
  fi

  EMAIL=$(jq -r '.email // empty' <<<"$raw")
  [[ -n $EMAIL ]] || EMAIL="${USERNAME}@${HOSTNAME}"

  for req in username hostname timezone theme terminal profile scale full_name; do
    var=${req^^}
    validate_answer_field "$req" "${!var}"
  done

  apply_answer_blocks
}

prompt_field() {
  local field="$1"
  local gum_type header prompt placeholder default_val pattern pattern_msg
  gum_type=$(jq -r --arg f "$field" '.fields[$f].gum // "input"' <<<"$(prompts_json)")
  header=$(jq -r --arg f "$field" '.fields[$f].header // ""' <<<"$(prompts_json)")
  prompt=$(jq -r --arg f "$field" '.fields[$f].prompt // "> "' <<<"$(prompts_json)")
  placeholder=$(jq -r --arg f "$field" '.fields[$f].placeholder // ""' <<<"$(prompts_json)")
  default_val=$(jq -r --arg f "$field" '.fields[$f].default // ""' <<<"$(prompts_json)")
  pattern=$(jq -r --arg f "$field" '.fields[$f].validate.pattern // ""' <<<"$(prompts_json)")
  pattern_msg=$(jq -r --arg f "$field" '.fields[$f].validate.message // "Invalid value."' <<<"$(prompts_json)")

  [[ -n $header ]] && echo "$header"

  local value=""
  case "$gum_type" in
  input)
    local is_pw
    is_pw=$(jq -r --arg f "$field" '.fields[$f].password // false' <<<"$(prompts_json)")
    while true; do
      if command -v gum >/dev/null 2>&1; then
        if [[ $is_pw == true ]]; then
          value=$(gum input --password --prompt "$prompt" --placeholder "$placeholder" || true)
        else
          value=$(gum input --prompt "$prompt" --placeholder "$placeholder" --value "$default_val" || true)
        fi
      else
        if [[ $is_pw == true ]]; then read -rsp "$prompt" value; echo
        else read -rp "$prompt" value; fi
      fi
      [[ -n $value ]] || continue
      if [[ -n $pattern && ! $value =~ $pattern ]]; then
        warn "$pattern_msg"
        continue
      fi
      if [[ $field == timezone ]] && ! valid_iana_timezone "$value"; then
        local tz_msg
        tz_msg=$(jq -r '.fields.timezone.validate.message // "Invalid timezone."' <<<"$(prompts_json)")
        warn "$tz_msg"
        continue
      fi
      if [[ $is_pw == true ]]; then
        local confirm_pw confirm_prompt mismatch
        confirm_prompt=$(jq -r '.fields.password.confirm.prompt // "Confirm> "' <<<"$(prompts_json)")
        mismatch=$(jq -r '.fields.password.confirm.mismatch // "Passwords did not match."' <<<"$(prompts_json)")
        if command -v gum >/dev/null 2>&1; then
          confirm_pw=$(gum input --password --prompt "$confirm_prompt" || true)
        else
          read -rsp "$confirm_prompt" confirm_pw; echo
        fi
        [[ $value == "$confirm_pw" ]] || { warn "$mismatch"; continue; }
      fi
      break
    done
    ;;
  choose)
    local -a choices=()
    mapfile -t choices < <(jq -r --arg f "$field" '.fields[$f].choices[]? | if type == "object" then .value else . end' <<<"$(prompts_json)")
    if command -v gum >/dev/null 2>&1; then
      value=$(gum choose --selected "$default_val" "${choices[@]}")
    else
      local i=1 c
      echo "Choices:"
      for c in "${choices[@]}"; do echo "  $i) $c"; ((i++)); done
      read -rp "$prompt" value
      if [[ $value =~ ^[0-9]+$ && $value -ge 1 && $value -le ${#choices[@]} ]]; then
        value=${choices[$((value - 1))]}
      fi
    fi
    ;;
  confirm)
    local answer
    if command -v gum >/dev/null 2>&1; then
      if gum confirm "$prompt"; then answer=true; else answer=false; fi
    else
      read -rp "$prompt [y/N] " answer
      [[ ${answer,,} == y* ]] && answer=true || answer=false
    fi
    value=$answer
    ;;
  *)
    die "Unknown prompt type for $field: $gum_type"
    ;;
  esac
  printf '%s' "$value"
}

collect_answers_interactive() {
  local intro_title intro_sub
  intro_title=$(jq -r '.intro.title // "Omahedron setup"' <<<"$(prompts_json)")
  intro_sub=$(jq -r '.intro.subtitle // ""' <<<"$(prompts_json)")
  echo
  log "$intro_title"
  [[ -n $intro_sub ]] && echo "$intro_sub"
  echo

  FINGERPRINT=false
  AUTOLOGIN=false
  local field
  while IFS= read -r field; do
    case "$field" in
    full_name) FULL_NAME=$(prompt_field full_name) ;;
    username) USERNAME=$(prompt_field username) ;;
    password) PASSWORD_HASH=$(hash_password "$(prompt_field password)") ;;
    hostname) HOSTNAME=$(prompt_field hostname) ;;
    timezone) TIMEZONE=$(prompt_field timezone) ;;
    theme) THEME=$(prompt_field theme) ;;
    terminal) TERMINAL=$(prompt_field terminal) ;;
    profile) PROFILE=$(prompt_field profile) ;;
    scale) SCALE=$(prompt_field scale) ;;
    fingerprint) FINGERPRINT=$(prompt_field fingerprint) ;;
    autologin) AUTOLOGIN=$(prompt_field autologin) ;;
    esac
  done < <(jq -r '.order[]' <<<"$(prompts_json)")

  EMAIL="${USERNAME}@${HOSTNAME}"
  apply_answer_blocks
}

collect_answers() {
  if [[ -n ${OMARCHY_SETUP_ANSWERS:-} ]]; then
    collect_answers_from_file "$OMARCHY_SETUP_ANSWERS"
    return 0
  fi
  collect_answers_interactive
}

guard_existing_config() {
  local target="$1" name path
  for name in flake.nix configuration.nix; do
    path="$target/$name"
    [[ -f $path ]] || continue
    if ((FORCE != 1)); then
      die "Refusing to overwrite $path (pass --force to back up and replace)."
    fi
    warn "Backing up $path -> $(backup_file_as_root "$path")"
  done
}

confirm_apply() {
  ((SKIP_CONFIRM == 1)) && return 0
  local ready_msg
  ready_msg=$(jq -r '.intro.ready // "Ready to write your configuration and rebuild."' <<<"$(prompts_json)")
  if command -v gum >/dev/null 2>&1; then
    gum confirm "$ready_msg" || die "Setup cancelled."
  else
    read -rp "$ready_msg [y/N] " ans
    [[ ${ans,,} == y* ]] || die "Setup cancelled."
  fi
}

copy_hardware_configuration() {
  local target="$1" dest="$target/hardware-configuration.nix"
  local src="" h

  if [[ -f $dest ]]; then
    h=$(hash_file "$dest")
    echo "hardware-configuration.nix sha256 $h (kept, not regenerated)"
    return 0
  fi

  for candidate in /etc/nixos/hardware-configuration.nix; do
    [[ -f $candidate ]] && src=$candidate && break
  done

  [[ -n $src ]] || die "$(prompt_err missingHardwareConfig)"

  local pre post
  pre=$(hash_file "$src")
  copy_file_as_root "$src" "$dest"
  post=$(hash_file "$dest")

  [[ $pre == "$post" ]] || die "hardware-configuration.nix copy hash mismatch — aborting."
  echo "hardware-configuration.nix sha256 $post (copied, not regenerated)"
}

print_dry_run_rebuild() {
  local target="$1"
  local rebuild_subcmd="${OMARCHY_NIX_REBUILD_CMD:-switch}"
  echo "DRY-RUN: nixos-rebuild $rebuild_subcmd --flake $target#$HOSTNAME --option extra-substituters $HYPR_CACHE_URL --option extra-trusted-public-keys $HYPR_CACHE_KEY"
}

run_setup() {
  require_linux_x86_64

  local target
  target=$(resolve_setup_target_dir)

  FINGERPRINT_BLOCK=''
  AUTOLOGIN_BLOCK=''
  collect_answers
  confirm_apply

  if [[ ! -d $target ]]; then
    if [[ -w $(dirname "$target") ]]; then mkdir -p "$target"
    else sudo mkdir -p "$target"
    fi
  fi

  guard_existing_config "$target"
  copy_hardware_configuration "$target"

  render_template "$TEMPLATE_DIR/flake.nix.template" "$target/flake.nix"
  render_template "$TEMPLATE_DIR/configuration.nix.template" "$target/configuration.nix"

  if [[ ${OMARCHY_SETUP_DRY_RUN:-} == 1 ]]; then
    print_dry_run_rebuild "$target"
    exit 0
  fi

  log "Locking flake inputs in $target ..."
  if [[ -w $target ]]; then
    (cd "$target" && nix flake lock)
  else
    sudo bash -c "cd '$target' && nix flake lock"
  fi

  local rebuild_subcmd="${OMARCHY_NIX_REBUILD_CMD:-switch}"
  log "Rebuilding (first apply uses the Hyprland/Mesa cache) ..."
  local rebuild_cmd=(
    nixos-rebuild "$rebuild_subcmd"
    --flake "$target#$HOSTNAME"
    --option extra-substituters "$HYPR_CACHE_URL"
    --option extra-trusted-public-keys "$HYPR_CACHE_KEY"
  )
  if sudo "${rebuild_cmd[@]}"; then
    log "Done. Log in at the greeter when the display manager restarts."
    if [[ -n $FINGERPRINT_BLOCK ]]; then
      warn "Fingerprint enabled — run fprintd-enroll after first login."
    fi
  else
    die "nixos-rebuild failed. Your previous system generation is unchanged."
  fi
}

show_help() {
  jq -r '
    .help.summary,
    "",
    .help.description,
    (.help.longDescription // empty | select(length > 0) | "\n" + .)
  ' <<<"$(prompts_json)"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h|--help|help)
      show_help
      exit 0
      ;;
    -y)
      SKIP_CONFIRM=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    *)
      die "Usage: omarchy setup [-y] [--force]"
      ;;
    esac
  done
  run_setup
}

main "$@"
