#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"
DEFAULTS_SCRIPT="$SCRIPT_DIR/defaults.sh"

# shellcheck source=../lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"

MODE=""
CATEGORY=""
OUTPUT_FILE=""

usage() {
  cat <<'EOF'
Usage: scripts/macos/export-defaults.sh [options]

Read current macOS defaults for the settings managed by scripts/macos/defaults.sh.

Options:
  --help             Show this help.
  --all              Inspect all managed settings.
  --category <name>  Inspect one category.
  --output <file>    Write the report to a text file.

Categories:
  global
  finder
  dock
  screenshots
  keyboard

Examples:
  scripts/macos/export-defaults.sh --all
  scripts/macos/export-defaults.sh --category finder
  scripts/macos/export-defaults.sh --all --output tmp/macos-defaults-before.txt

Safety:
  - Read-only: uses defaults read for specific domain/key pairs only.
  - No defaults write, sudo, killall, app restarts, package installs, or chezmoi apply.
EOF
}

actions() {
  awk '
    /^actions\(\) \{/ {
      in_actions = 1
      next
    }
    in_actions && /^  cat <<EOF$/ {
      in_heredoc = 1
      next
    }
    in_actions && in_heredoc && /^EOF$/ {
      exit
    }
    in_actions && in_heredoc {
      print
    }
  ' "$DEFAULTS_SCRIPT"
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

  [[ "$MODE" == "all" || "$CATEGORY" == "$action_category" ]]
}

read_default_value() {
  local domain="$1"
  local key="$2"
  local value

  if value="$(defaults read "$domain" "$key" 2>/dev/null)"; then
    if [[ -n "$value" ]]; then
      printf '%s\n' "$value"
    else
      printf '<empty>\n'
    fi
  else
    printf '<not set>\n'
  fi
}

render_report() {
  local category
  local description
  local domain
  local key
  local type
  local value
  local restart
  local risk
  local current_category=""
  local current_value
  local count=0

  printf 'macOS defaults report\n'
  printf 'Generated: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || date)"
  printf 'Source: %s\n' "$DEFAULTS_SCRIPT"
  if [[ "$MODE" == "category" ]]; then
    printf 'Category: %s\n' "$CATEGORY"
  else
    printf 'Category: all\n'
  fi

  while IFS='|' read -r category description domain key type value restart risk; do
    matches_category "$category" || continue
    count=$((count + 1))

    if [[ "$category" != "$current_category" ]]; then
      printf '\n[%s]\n' "$category"
      current_category="$category"
    fi

    current_value="$(read_default_value "$domain" "$key")"

    printf '  - description: %s\n' "$description"
    printf '    domain: %s\n' "$domain"
    printf '    key: %s\n' "$key"
    printf '    current value: %s\n' "$current_value"
  done < <(actions)

  if ((count == 0)); then
    die "no settings found for category: ${CATEGORY:-all}"
  fi
}

write_report() {
  local parent

  if [[ -z "$OUTPUT_FILE" ]]; then
    render_report
    return 0
  fi

  parent="$(dirname -- "$OUTPUT_FILE")"
  if [[ -n "$parent" && "$parent" != "." && ! -d "$parent" ]]; then
    mkdir -p "$parent"
  fi

  render_report >"$OUTPUT_FILE"
  log_info "Wrote macOS defaults report to $OUTPUT_FILE"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help | -h)
        MODE="help"
        ;;
      --all)
        [[ -z "$MODE" ]] || die "choose only one inspection mode: --all or --category"
        MODE="all"
        ;;
      --category)
        [[ -z "$MODE" ]] || die "choose only one inspection mode: --all or --category"
        shift
        [[ $# -gt 0 ]] || die "--category requires a value"
        CATEGORY="$1"
        MODE="category"
        ;;
      --output)
        shift
        [[ $# -gt 0 ]] || die "--output requires a file path"
        OUTPUT_FILE="$1"
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

  if [[ "$MODE" == "help" || -z "$MODE" ]]; then
    usage
    return 0
  fi

  if ! is_macos; then
    log_info "This script only applies to macOS. Current platform: $(uname -s 2>/dev/null || printf 'unknown')"
    return 0
  fi

  [[ -r "$DEFAULTS_SCRIPT" ]] || die "could not read managed defaults script: $DEFAULTS_SCRIPT"

  if [[ "$MODE" == "category" ]] && ! category_exists "$CATEGORY"; then
    die "invalid category: $CATEGORY. Use --help to see valid categories."
  fi

  write_report
}

main "$@"
