#!/usr/bin/env bash
# Shared helpers for dotfiles repository scripts.

__DOTFILES_COMMON_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P 2>/dev/null || pwd -P)"

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_warn() {
  printf '[WARN] %s\n' "$*" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

die() {
  log_error "$*"
  exit 1
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

is_macos() {
  [[ "$(uname -s 2>/dev/null)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname -s 2>/dev/null)" == "Linux" ]]
}

confirm() {
  local prompt="${1:-Continue?}"
  local reply

  printf '%s [y/N] ' "$prompt" >&2
  if ! IFS= read -r reply; then
    return 1
  fi

  case "$reply" in
    [Yy] | [Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

run_cmd() {
  [[ $# -gt 0 ]] || die "run_cmd requires a command"

  case "${DRY_RUN:-0}" in
    1 | true | TRUE | yes | YES)
      printf '[DRY-RUN]'
      printf ' %q' "$@"
      printf '\n'
      ;;
    *)
      "$@"
      ;;
  esac
}

ensure_dir() {
  local dir="${1:-}"

  [[ -n "$dir" ]] || die "ensure_dir requires a directory path"
  [[ -d "$dir" ]] && return 0

  run_cmd mkdir -p "$dir"
}

repo_root() {
  local candidate
  local root

  if [[ -n "${__DOTFILES_COMMON_DIR:-}" && -d "$__DOTFILES_COMMON_DIR/../.." ]]; then
    candidate="$(cd "$__DOTFILES_COMMON_DIR/../.." && pwd -P)"
    if has_command git; then
      if root="$(git -C "$candidate" rev-parse --show-toplevel 2>/dev/null)"; then
        printf '%s\n' "$root"
        return 0
      fi
    fi
    printf '%s\n' "$candidate"
    return 0
  fi

  if has_command git; then
    if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
      printf '%s\n' "$root"
      return 0
    fi
  fi

  pwd -P
}
