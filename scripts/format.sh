#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
MODE="check"
SHELL_FILES=()

usage() {
  cat <<'EOF'
Usage: scripts/format.sh [--check|--write|--help]

Format shell scripts in this repository with shfmt.

Modes:
  --check   Show formatting diffs and exit non-zero if changes are needed.
            This is the default.
  --write   Rewrite shell scripts in place.
  --help    Show this help text.
EOF
}

relpath() {
  local path="$1"

  case "$path" in
    "$ROOT"/*) printf '%s\n' "${path#"$ROOT"/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

is_shell_script() {
  local file="$1"
  local first_line=""

  case "$file" in
    *.sh | *.sh.tmpl) return 0 ;;
  esac

  IFS= read -r first_line <"$file" || true
  case "$first_line" in
    '#!'*bash* | '#!'*'/sh'* | '#!'*zsh*) return 0 ;;
    *) return 1 ;;
  esac
}

add_shell_file() {
  local file="$1"

  [[ -f "$file" ]] || return 0
  is_shell_script "$file" || return 0
  SHELL_FILES+=("$file")
}

collect_shell_files() {
  local file

  SHELL_FILES=()

  for file in "$ROOT"/scripts/*.sh "$ROOT"/scripts/lib/*.sh; do
    add_shell_file "$file"
  done

  if [[ -d "$ROOT/dot_local/bin" ]]; then
    for file in "$ROOT"/dot_local/bin/executable_*; do
      add_shell_file "$file"
    done
  fi

  for file in "$ROOT"/run_*; do
    add_shell_file "$file"
  done
}

check_format() {
  local file
  local output
  local needs_format=0

  for file in "${SHELL_FILES[@]}"; do
    if output="$(shfmt -i 2 -ci -d "$file" 2>&1)"; then
      if [[ -n "$output" ]]; then
        printf '%s\n' "$output"
        needs_format=1
      fi
    else
      printf '%s\n' "$output"
      needs_format=1
    fi
  done

  if ((needs_format != 0)); then
    die "Formatting check failed. Run scripts/format.sh --write to update shell files."
  fi

  log_info "All shell scripts are formatted."
}

write_format() {
  local file

  for file in "${SHELL_FILES[@]}"; do
    log_info "Formatting $(relpath "$file")"
    run_cmd shfmt -i 2 -ci -w "$file"
  done
}

main() {
  case "${1:-}" in
    -h | --help)
      usage
      return 0
      ;;
    --check | "")
      MODE="check"
      ;;
    --write)
      MODE="write"
      ;;
    *)
      usage >&2
      return 2
      ;;
  esac

  if ! has_command shfmt; then
    die "shfmt is not installed. Install it with Homebrew, for example: brew install shfmt"
  fi

  collect_shell_files
  if ((${#SHELL_FILES[@]} == 0)); then
    log_warn "No shell scripts found to format."
    return 0
  fi

  case "$MODE" in
    check) check_format ;;
    write) write_format ;;
    *) die "unknown format mode: $MODE" ;;
  esac
}

main "$@"
