#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"

# shellcheck source=../lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"

MODE="help"
MODE_SET=0
CATEGORY=""
NO_RESTART=0
FORCE=0
SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"

usage() {
  cat <<'EOF'
Usage: scripts/macos/defaults.sh [options]

Safely inspect or apply conservative macOS defaults by category.

Options:
  --help             Show this help.
  --list             List available settings grouped by category.
  --dry-run          Print the exact commands that would run.
  --apply            Apply selected settings after confirmation.
  --force            Apply settings without confirmation (use with --apply).
  --category <name>  Limit to one category.
  --no-restart       Do not restart affected apps/services after apply.

Categories:
  global
  finder
  dock
  screenshots
  keyboard

Examples:
  scripts/macos/export-defaults.sh --all
  scripts/macos/defaults.sh --list
  scripts/macos/defaults.sh --dry-run
  scripts/macos/defaults.sh --category finder --dry-run
  scripts/macos/defaults.sh --category screenshots --apply

Recommended flow:
  1. Export current values.
  2. Review --dry-run output.
  3. Apply one category at a time.

Safety:
  - No sudo commands.
  - No package installation.
  - No privacy, security, power, network, or locale changes.
  - No Dock content reset, Launchpad reset, app data deletion, or chezmoi apply.
EOF
}

actions() {
  local line
  local data_file="$SCRIPT_DIR/macos-defaults.md"

  if [[ ! -f "$data_file" ]]; then
    die "defaults data file not found: $data_file"
  fi

  while IFS='|' read -r _ category description domain key type value restart risk _ || [[ -n "$category" ]]; do
    # Skip empty lines, non-table lines, and markdown headers/separators
    [[ -z "$category" || "$category" == *---* || "$category" == *"Category"* ]] && continue

    # Pure Bash whitespace trimming (fast, no subshells)
    category="${category#"${category%%[![:space:]]*}"}"; category="${category%"${category##*[![:space:]]}"}"
    description="${description#"${description%%[![:space:]]*}"}"; description="${description%"${description##*[![:space:]]}"}"
    domain="${domain#"${domain%%[![:space:]]*}"}"; domain="${domain%"${domain##*[![:space:]]}"}"
    key="${key#"${key%%[![:space:]]*}"}"; key="${key%"${key##*[![:space:]]}"}"
    type="${type#"${type%%[![:space:]]*}"}"; type="${type%"${type##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"; value="${value%"${value##*[![:space:]]}"}"
    restart="${restart#"${restart%%[![:space:]]*}"}"; restart="${restart%"${restart##*[![:space:]]}"}"
    risk="${risk#"${risk%%[![:space:]]*}"}"; risk="${risk%"${risk##*[![:space:]]}"}"

    [[ -z "$domain" ]] && continue

    # Replace variables with actual values
    value="${value//\$\{SCREENSHOT_DIR\}/$SCREENSHOT_DIR}"
    value="${value//\$\{HOME\}/$HOME}"

    printf '%s|%s|%s|%s|%s|%s|%s|%s\n' "$category" "$description" "$domain" "$key" "$type" "$value" "$restart" "$risk"
  done < "$data_file"
}

category_exists() {
  local wanted="$1"
  local category
  local rest

  while IFS='|' read -r category rest; do
    [[ -n "$category" ]] || continue
    if [[ "$category" == "$wanted" ]]; then
      return 0
    fi
  done < <(actions)

  return 1
}

matches_category() {
  local action_category="$1"

  [[ -z "$CATEGORY" || "$CATEGORY" == "$action_category" ]]
}

defaults_command() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [[ "$type" == "plist-string" ]]; then
    local path="$domain"
    if [[ "$path" != /* && "$path" != ~* ]]; then
      path="~/Library/Preferences/${domain}.plist"
    fi
    printf '/usr/libexec/PlistBuddy -c "Set %s %s" %s' "$key" "$value" "$path"
  else
    printf 'defaults write %q %q -%s %q' "$domain" "$key" "$type" "$value"
  fi
}

run_defaults_write() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  case "$type" in
    bool | int | float | string)
      defaults write "$domain" "$key" "-$type" "$value"
      ;;
    plist-string)
      local path="$domain"
      if [[ "$path" != /* && "$path" != ~* ]]; then
        # Expand ~ if present in domain (though usually it's com.apple.xxx)
        if [[ "$path" == ~* ]]; then
           path="${path/#\~/$HOME}"
        else
           path="${HOME}/Library/Preferences/${domain}.plist"
        fi
      elif [[ "$path" == ~* ]]; then
        path="${path/#\~/$HOME}"
      fi
      
      # Use PlistBuddy to set or add the nested key
      /usr/libexec/PlistBuddy -c "Set ${key} ${value}" "$path" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Add ${key} string ${value}" "$path" 2>/dev/null
      ;;
    *)
      die "unsupported defaults value type: $type"
      ;;
  esac
}

collect_restart_targets() {
  local category
  local description
  local domain
  local key
  local type
  local value
  local restart
  local risk
  local targets=()
  local target

  while IFS='|' read -r category description domain key type value restart risk; do
    matches_category "$category" || continue
    [[ -n "$restart" ]] || continue

    for target in "${targets[@]}"; do
      [[ "$target" == "$restart" ]] && continue 2
    done
    targets+=("$restart")
  done < <(actions)

  printf '%s\n' "${targets[@]}"
}

list_actions() {
  local category
  local description
  local domain
  local key
  local type
  local value
  local restart
  local risk
  local current_category=""
  local count=0

  while IFS='|' read -r category description domain key type value restart risk; do
    matches_category "$category" || continue
    count=$((count + 1))

    if [[ "$category" != "$current_category" ]]; then
      printf '\n[%s]\n' "$category"
      current_category="$category"
    fi

    printf '  - %s\n' "$description"
    printf '    command: '
    defaults_command "$domain" "$key" "$type" "$value"
    printf '\n'
    printf '    risk: %s' "$risk"
    if [[ -n "$restart" ]]; then
      printf ', restart: %s' "$restart"
    fi
    printf '\n'
  done < <(actions)

  if ((count == 0)); then
    die "no settings found for category: ${CATEGORY:-all}"
  fi
}

dry_run() {
  local category
  local description
  local domain
  local key
  local type
  local value
  local restart
  local risk
  local target

  log_info "Dry run only. No settings will be changed."

  while IFS='|' read -r category description domain key type value restart risk; do
    matches_category "$category" || continue
    printf '\n# [%s] %s\n' "$category" "$description"

    if [[ "$category" == "screenshots" && "$key" == "location" ]]; then
      printf 'mkdir -p %q\n' "$value"
    fi

    defaults_command "$domain" "$key" "$type" "$value"
    printf '\n'
  done < <(actions)

  if [[ "$NO_RESTART" -eq 1 ]]; then
    printf '\n# Restarts suppressed by --no-restart\n'
    return 0
  fi

  printf '\n# Restart affected apps/services after apply\n'
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    printf 'killall %q\n' "$target"
  done < <(collect_restart_targets)
}

apply_settings() {
  local category
  local description
  local domain
  local key
  local type
  local value
  local restart
  local risk
  local target
  local restart_targets=()

  log_warn "This will apply macOS defaults for category: ${CATEGORY:-all}"
  log_warn "No sudo commands will be run."
  log_warn "Run --dry-run first if you have not reviewed the exact commands."

  if [[ "$NO_RESTART" -eq 1 ]]; then
    log_info "App/service restarts are suppressed by --no-restart."
  else
    while IFS= read -r target; do
      [[ -n "$target" ]] || continue
      restart_targets+=("$target")
    done < <(collect_restart_targets)

    if ((${#restart_targets[@]} > 0)); then
      log_warn "After applying, these apps/services will be restarted: ${restart_targets[*]}"
    fi
  fi

  if [[ "$FORCE" -eq 1 ]]; then
    log_info "Skipping confirmation because --force was provided."
  elif ! confirm "Apply these macOS defaults now?"; then
    log_info "Apply cancelled."
    return 0
  fi

  while IFS='|' read -r category description domain key type value restart risk; do
    matches_category "$category" || continue
    log_info "Applying [$category] $description"

    if [[ "$category" == "screenshots" && "$key" == "location" ]]; then
      ensure_dir "$value"
    fi

    run_defaults_write "$domain" "$key" "$type" "$value"
  done < <(actions)

  if [[ "$NO_RESTART" -eq 1 ]]; then
    log_info "Skipping restarts because --no-restart was provided."
    return 0
  fi

  for target in "${restart_targets[@]}"; do
    [[ -n "$target" ]] || continue
    log_info "Restarting $target"
    killall "$target" >/dev/null 2>&1 || log_warn "$target was not running or could not be restarted."
  done

  log_info "Done. Some changes may require logging out or relaunching apps."
}

parse_args() {
  local requested_mode

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help | -h)
        requested_mode="help"
        if [[ "$MODE_SET" -eq 1 ]]; then
          die "choose only one mode: --help, --list, --dry-run, or --apply"
        fi
        MODE="$requested_mode"
        MODE_SET=1
        ;;
      --list)
        requested_mode="list"
        if [[ "$MODE_SET" -eq 1 ]]; then
          die "choose only one mode: --help, --list, --dry-run, or --apply"
        fi
        MODE="$requested_mode"
        MODE_SET=1
        ;;
      --dry-run)
        requested_mode="dry-run"
        if [[ "$MODE_SET" -eq 1 ]]; then
          die "choose only one mode: --help, --list, --dry-run, or --apply"
        fi
        MODE="$requested_mode"
        MODE_SET=1
        ;;
      --apply)
        requested_mode="apply"
        if [[ "$MODE_SET" -eq 1 ]]; then
          die "choose only one mode: --help, --list, --dry-run, or --apply"
        fi
        MODE="$requested_mode"
        MODE_SET=1
        ;;
      --force)
        FORCE=1
        ;;
      --category)
        shift
        [[ $# -gt 0 ]] || die "--category requires a value"
        CATEGORY="$1"
        ;;
      --no-restart)
        NO_RESTART=1
        ;;
      *)
        usage >&2
        die "unknown argument: $1"
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  if ! is_macos; then
    log_info "This script only applies to macOS. Current platform: $(uname -s 2>/dev/null || printf 'unknown')"
    return 0
  fi

  if [[ -n "$CATEGORY" ]] && ! category_exists "$CATEGORY"; then
    die "invalid category: $CATEGORY. Use --list to see valid categories."
  fi

  case "$MODE" in
    help)
      usage
      ;;
    list)
      list_actions
      ;;
    dry-run)
      dry_run
      ;;
    apply)
      apply_settings
      ;;
    *)
      die "unknown mode: $MODE"
      ;;
  esac
}

main "$@"
