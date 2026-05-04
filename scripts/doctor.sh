#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

FAIL_COUNT=0
WARN_COUNT=0

usage() {
  cat <<'EOF'
Usage: scripts/doctor.sh [--help]

Run a read-only health check for this chezmoi-managed dotfiles repository.

The doctor reports PASS/WARN/FAIL checks and exits non-zero only when critical
checks fail. It does not create directories, install packages, or apply chezmoi.
EOF
}

pass_check() {
  local name="$1"
  local message="${2:-ok}"

  printf '[PASS] %-28s %s\n' "$name" "$message"
}

warn_check() {
  local name="$1"
  local message="$2"

  WARN_COUNT=$((WARN_COUNT + 1))
  printf '[WARN] %-28s %s\n' "$name" "$message"
}

fail_check() {
  local name="$1"
  local message="$2"

  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '[FAIL] %-28s %s\n' "$name" "$message"
}

command_version() {
  local cmd="$1"

  case "$cmd" in
    bash) bash --version 2>/dev/null | sed -n '1p' ;;
    brew) brew --version 2>/dev/null | sed -n '1p' ;;
    chezmoi) chezmoi --version 2>/dev/null ;;
    code) code --version 2>/dev/null | sed -n '1p' ;;
    curl) curl --version 2>/dev/null | sed -n '1p' ;;
    gh) gh --version 2>/dev/null | sed -n '1p' ;;
    git) git --version 2>/dev/null ;;
    shfmt) shfmt --version 2>/dev/null ;;
    shellcheck) shellcheck --version 2>/dev/null | sed -n '2p' ;;
    vim) vim --version 2>/dev/null | sed -n '1p' ;;
    zsh) zsh --version 2>/dev/null ;;
    *) "$cmd" --version 2>/dev/null | sed -n '1p' ;;
  esac
}

check_command() {
  local cmd="$1"
  local level="$2"
  local label="${3:-$cmd}"
  local version

  if has_command "$cmd"; then
    version="$(command_version "$cmd" || true)"
    pass_check "$label" "${version:-found}"
    return 0
  fi

  case "$level" in
    fail) fail_check "$label" "not found in PATH" ;;
    warn) warn_check "$label" "not found in PATH" ;;
    *) die "unknown check level: $level" ;;
  esac
}

check_os() {
  local os
  local arch

  os="$(uname -s 2>/dev/null || printf 'unknown')"
  arch="$(uname -m 2>/dev/null || printf 'unknown')"

  if is_macos; then
    pass_check "OS" "macOS/Darwin ($arch)"
  elif is_linux; then
    pass_check "OS" "Linux ($arch)"
  else
    warn_check "OS" "unsupported or untested platform: $os/$arch"
  fi
}

check_context() {
  local cwd
  local user
  local shell_name

  cwd="$(pwd -P)"
  user="$(id -un 2>/dev/null || printf '%s' "${USER:-unknown}")"
  shell_name="${SHELL:-unknown}"

  check_os
  pass_check "Current shell" "$shell_name"
  pass_check "Current user" "$user"
  pass_check "Current directory" "$cwd"
}

check_git_repo() {
  local root

  if has_command git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
    pass_check "Git repository" "inside work tree: $root"
  elif [[ -d ".git" ]]; then
    pass_check "Git repository" ".git directory found"
  else
    fail_check "Git repository" "current directory is not inside a Git work tree"
  fi
}

check_home_paths() {
  if [[ -d "$HOME/.local/bin" ]]; then
    pass_check "\$HOME/.local/bin" "exists"
  else
    warn_check "\$HOME/.local/bin" "missing; daily commands will not be installed there until chezmoi creates it"
  fi

  if [[ -d "$HOME/.config" ]]; then
    pass_check "\$HOME/.config" "exists"
  else
    warn_check "\$HOME/.config" "missing"
  fi

  case ":${PATH:-}:" in
    *":$HOME/.local/bin:"*) pass_check "PATH" "\$HOME/.local/bin is present" ;;
    *) warn_check "PATH" "\$HOME/.local/bin is not present" ;;
  esac
}

check_chezmoi_source() {
  local root
  local source_path

  root="$(repo_root)"

  if [[ -f "$root/.chezmoiignore" && -f "$root/dot_zshrc" && -d "$root/dot_config" ]]; then
    pass_check "Chezmoi source shape" "dotfiles source files found"
  else
    fail_check "Chezmoi source shape" "missing expected chezmoi files under $root"
  fi

  if has_command chezmoi; then
    source_path="$(chezmoi source-path 2>/dev/null || true)"
    if [[ -n "$source_path" && "$source_path" == "$root" ]]; then
      pass_check "Chezmoi source path" "$source_path"
    elif [[ -n "$source_path" ]]; then
      warn_check "Chezmoi source path" "configured as $source_path; script root is $root"
    else
      warn_check "Chezmoi source path" "could not read chezmoi source path"
    fi
  else
    fail_check "Chezmoi source path" "chezmoi is not available"
  fi
}

check_tools() {
  check_command git fail "Git"
  check_command chezmoi fail "Chezmoi"

  if is_macos; then
    check_command brew warn "Homebrew"
  fi

  check_command vim warn "Vim"
  check_command curl warn "Curl"
  check_command bash fail "Bash"
  check_command zsh fail "Zsh"

  check_command shellcheck warn "ShellCheck"
  check_command shfmt warn "shfmt"
  check_command gh warn "GitHub CLI"
  check_command code warn "VS Code CLI"
}

main() {
  case "${1:-}" in
    -h | --help)
      usage
      return 0
      ;;
    "")
      ;;
    *)
      usage >&2
      return 2
      ;;
  esac

  log_info "Dotfiles doctor (read-only)"
  printf '\n'

  check_context
  check_git_repo
  check_tools
  check_home_paths
  check_chezmoi_source

  printf '\n'
  if ((FAIL_COUNT > 0)); then
    log_error "Doctor finished with $FAIL_COUNT failure(s) and $WARN_COUNT warning(s)."
    return 1
  fi

  log_info "Doctor finished with no critical failures and $WARN_COUNT warning(s)."
}

main "$@"
