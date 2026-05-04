#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

MODE="plan"
FAIL_COUNT=0
WARN_COUNT=0
ROOT="$(repo_root)"

usage() {
  cat <<'EOF'
Usage: scripts/bootstrap.sh [--dry-run | --apply] [--help]

Prepare a new machine to use this chezmoi-managed dotfiles repository safely.

Modes:
  default     Print checks, guidance, and next recommended commands.
  --dry-run   Run read-only checks and chezmoi apply --dry-run for this source.
  --apply     Ask for confirmation, then run chezmoi apply for this source.
  --help      Show this help.

This script does not install packages, edit shell profiles, create directories,
or apply chezmoi unless --apply is passed and confirmation is given.
EOF
}

section() {
  printf '\n== %s ==\n' "$1"
}

ok() {
  printf '[OK] %s\n' "$*"
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  log_warn "$*"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  log_error "$*"
}

indent_text() {
  local text="${1:-}"
  local line

  [[ -n "$text" ]] || return 0
  while IFS= read -r line; do
    printf '  %s\n' "$line"
  done <<<"$text"
}

print_command() {
  printf '  %s\n' "$*"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help | -h)
        usage
        exit 0
        ;;
      --dry-run)
        [[ "$MODE" == "plan" ]] || die "choose only one mode: --dry-run or --apply"
        MODE="dry-run"
        ;;
      --apply)
        [[ "$MODE" == "plan" ]] || die "choose only one mode: --dry-run or --apply"
        MODE="apply"
        ;;
      *)
        usage >&2
        die "unknown argument: $1"
        ;;
    esac
    shift
  done
}

check_os() {
  local os
  local arch

  section "1. Platform"

  os="$(uname -s 2>/dev/null || printf 'unknown')"
  arch="$(uname -m 2>/dev/null || printf 'unknown')"

  if is_macos; then
    ok "OS: macOS/Darwin ($arch)"
  elif is_linux; then
    ok "OS: Linux ($arch)"
  else
    warn "Unsupported or untested OS: $os/$arch"
  fi
}

check_basics() {
  local status_output

  section "2. Required Basics"

  if has_command git; then
    ok "Git: $(git --version 2>/dev/null || printf 'found')"
  else
    fail "Git is required but was not found in PATH."
  fi

  if has_command chezmoi; then
    ok "Chezmoi: $(chezmoi --version 2>/dev/null || printf 'found')"
  else
    fail "Chezmoi is required but was not found in PATH."
  fi

  ok "Repository root: $ROOT"

  if [[ -d "$ROOT/.git" ]] || { has_command git && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; }; then
    ok "Repository: Git work tree detected"
  else
    fail "Repository root does not appear to be a Git work tree: $ROOT"
  fi

  if has_command git && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    status_output="$(git -C "$ROOT" status --short 2>/dev/null || true)"
    if [[ -z "$status_output" ]]; then
      ok "Repository status: clean"
    else
      warn "Repository status: uncommitted changes are present"
      indent_text "$status_output"
    fi
  fi
}

print_homebrew_guidance() {
  cat <<'EOF'
Homebrew is not installed. Install it manually from the official site:

  https://brew.sh/

Common macOS install command shown by Homebrew:

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

After Homebrew is installed:

  brew install git chezmoi
EOF
}

check_macos() {
  local brew_version

  section "3. macOS Checks"

  if ! is_macos; then
    ok "Homebrew: skipped on non-macOS platform"
    return 0
  fi

  if has_command brew; then
    brew_version="$(brew --version 2>/dev/null | sed -n '1p' || printf 'found')"
    ok "Homebrew: ${brew_version:-found}"
  else
    warn "Homebrew is missing. It will not be installed automatically."
    print_homebrew_guidance
  fi
}

check_directories() {
  section "4. Directory Checks"

  if [[ -d "$HOME/.local/bin" ]]; then
    ok "\$HOME/.local/bin exists"
  else
    warn "\$HOME/.local/bin is missing. Not creating it in this mode."
  fi

  if [[ -d "$HOME/.config" ]]; then
    ok "\$HOME/.config exists"
  else
    warn "\$HOME/.config is missing. Not creating it in this mode."
  fi
}

check_chezmoi_source() {
  local source_path

  section "5. Chezmoi Source"

  if [[ -f "$ROOT/.chezmoiignore" && -f "$ROOT/dot_zshrc" && -d "$ROOT/dot_config" ]]; then
    ok "Source shape: expected chezmoi files found"
  else
    fail "Source shape: missing expected chezmoi files under $ROOT"
  fi

  if ! has_command chezmoi; then
    warn "Skipping chezmoi source-path and status because chezmoi is unavailable."
    return 0
  fi

  source_path="$(chezmoi source-path 2>/dev/null || true)"
  if [[ -n "$source_path" ]]; then
    ok "Configured chezmoi source-path: $source_path"
    if [[ "$source_path" != "$ROOT" ]]; then
      warn "Configured chezmoi source differs from this script root."
    fi
  else
    warn "Could not read chezmoi source-path."
  fi

  show_chezmoi_status
}

show_chezmoi_status() {
  local status_output

  log_info "Running read-only chezmoi status for this source..."
  if status_output="$(chezmoi --source "$ROOT" status 2>&1)"; then
    if [[ -z "$status_output" ]]; then
      ok "chezmoi status: no pending target changes"
    else
      warn "chezmoi status reported pending target changes or messages:"
      indent_text "$status_output"
    fi
  else
    warn "chezmoi status failed:"
    indent_text "$status_output"
  fi
}

run_chezmoi_dry_run() {
  local dry_run_output

  section "6. Chezmoi Dry Run"

  if ! has_command chezmoi; then
    fail "Cannot run chezmoi apply --dry-run because chezmoi is unavailable."
    return 0
  fi

  if [[ "$MODE" == "plan" ]]; then
    log_info "Default mode does not execute chezmoi apply --dry-run."
    log_info "Suggested command:"
    print_command "chezmoi --source \"$ROOT\" apply --dry-run"
    return 0
  fi

  log_info "Running read-only chezmoi apply --dry-run for this source..."
  log_info "Using --force only with --dry-run to avoid non-interactive prompts; no files are modified."
  if dry_run_output="$(chezmoi --source "$ROOT" apply --dry-run --force --no-tty 2>&1)"; then
    if [[ -z "$dry_run_output" ]]; then
      ok "chezmoi apply --dry-run: completed without output"
    else
      indent_text "$dry_run_output"
    fi
  else
    fail "chezmoi apply --dry-run failed."
    indent_text "$dry_run_output"
  fi
}

maybe_apply_chezmoi() {
  section "7. Apply"

  if [[ "$MODE" != "apply" ]]; then
    log_info "Not applying changes. Re-run with --apply when ready."
    return 0
  fi

  if ((FAIL_COUNT > 0)); then
    fail "Skipping apply because critical checks failed."
    return 0
  fi

  log_warn "This will run chezmoi apply for source: $ROOT"
  log_warn "Review the status and dry-run output above before confirming."

  if confirm "Run chezmoi apply now?"; then
    run_cmd chezmoi --source "$ROOT" apply
    ok "chezmoi apply completed"
  else
    log_info "Apply cancelled."
  fi
}

print_next_steps() {
  section "Next Recommended Commands"

  if is_macos && ! has_command brew; then
    print_command "open https://brew.sh/"
    print_command "brew install git chezmoi"
  elif is_linux; then
    print_command "Install git and chezmoi with your distribution package manager or chezmoi's official install docs."
  fi

  print_command "scripts/doctor.sh"
  print_command "chezmoi --source \"$ROOT\" apply --dry-run"
  print_command "scripts/bootstrap.sh --apply"
}

main() {
  parse_args "$@"

  log_info "Dotfiles bootstrap helper"
  log_info "Mode: $MODE"
  log_info "This script is conservative and read-only unless --apply is confirmed."

  check_os
  check_basics
  check_macos
  check_directories
  check_chezmoi_source
  run_chezmoi_dry_run
  maybe_apply_chezmoi
  print_next_steps

  if ((FAIL_COUNT > 0)); then
    log_error "Bootstrap finished with $FAIL_COUNT failure(s) and $WARN_COUNT warning(s)."
    return 1
  fi

  log_info "Bootstrap finished with no critical failures and $WARN_COUNT warning(s)."
}

main "$@"
