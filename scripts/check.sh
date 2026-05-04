#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
FAIL_COUNT=0
WARN_COUNT=0
SHELL_FILES=()

usage() {
  cat <<'EOF'
Usage: scripts/check.sh [--help]

Run read-only quality and safety checks for this dotfiles repository.

Checks include Bash syntax, optional ShellCheck, optional shfmt diff, lightweight
secret scanning, a safe chezmoi source check, and executable permission warnings.
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

check_bash_syntax() {
  local file
  local checked=0

  collect_shell_files

  if ((${#SHELL_FILES[@]} == 0)); then
    warn_check "Bash syntax" "no shell scripts found"
    return 0
  fi

  for file in "${SHELL_FILES[@]}"; do
    checked=$((checked + 1))
    if bash -n "$file"; then
      pass_check "bash -n" "$(relpath "$file")"
    else
      fail_check "bash -n" "$(relpath "$file")"
    fi
  done

  pass_check "Bash syntax" "checked $checked shell script(s)"
}

check_shellcheck() {
  local file

  if ! has_command shellcheck; then
    warn_check "ShellCheck" "not installed; skipping"
    return 0
  fi

  for file in "${SHELL_FILES[@]}"; do
    if shellcheck -x "$file"; then
      pass_check "ShellCheck" "$(relpath "$file")"
    else
      fail_check "ShellCheck" "$(relpath "$file")"
    fi
  done
}

check_shfmt() {
  local file
  local output

  if ! has_command shfmt; then
    warn_check "shfmt" "not installed; skipping format check"
    return 0
  fi

  for file in "${SHELL_FILES[@]}"; do
    if output="$(shfmt -i 2 -ci -d "$file" 2>&1)"; then
      if [[ -n "$output" ]]; then
        printf '%s\n' "$output"
        fail_check "shfmt" "$(relpath "$file") needs formatting"
      else
        pass_check "shfmt" "$(relpath "$file")"
      fi
    else
      printf '%s\n' "$output"
      fail_check "shfmt" "$(relpath "$file") could not be parsed"
    fi
  done
}

scan_file_for_secrets() {
  local file="$1"
  local base
  local private_key_regex='-----BEGIN [A-Z ]*PRIVATE KEY-----'
  local generic_secret_regex='(api[_-]?key|access[_-]?key|secret|token|password|passwd)[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9_./+=:-]{20,}'
  local aws_key_regex='AKIA[0-9A-Z]{16}'
  local github_token_regex='gh[pousr]_[A-Za-z0-9_]{30,}'
  local generic_token_regex='sk-[A-Za-z0-9]{20,}'

  base="$(basename -- "$file")"
  case "$base" in
    .env)
      fail_check "Secret scan" "$(relpath "$file") is a .env file"
      ;;
    .env.*)
      warn_check "Secret scan" "$(relpath "$file") is an env-like file"
      ;;
  esac

  grep -Iq . "$file" 2>/dev/null || return 0

  if grep -Eiq -e "$private_key_regex" "$file"; then
    fail_check "Secret scan" "$(relpath "$file") contains a private key marker"
  fi

  if grep -Eiq -e "$aws_key_regex" "$file"; then
    fail_check "Secret scan" "$(relpath "$file") contains an AWS-style access key"
  fi

  if grep -Eiq -e "$github_token_regex" "$file"; then
    fail_check "Secret scan" "$(relpath "$file") contains a GitHub-style token"
  fi

  if grep -Eiq -e "$generic_token_regex" "$file"; then
    fail_check "Secret scan" "$(relpath "$file") contains a token-like value"
  fi

  if grep -Eiq -e "$generic_secret_regex" "$file"; then
    fail_check "Secret scan" "$(relpath "$file") contains a secret-like assignment"
  fi
}

check_secret_scan() {
  local file
  local before_fail="$FAIL_COUNT"
  local before_warn="$WARN_COUNT"

  while IFS= read -r -d '' file; do
    scan_file_for_secrets "$file"
  done < <(find "$ROOT" -type f ! -path "$ROOT/.git/*" -print0)

  if [[ "$before_fail" == "$FAIL_COUNT" && "$before_warn" == "$WARN_COUNT" ]]; then
    pass_check "Secret scan" "no obvious secrets found"
  fi
}

check_chezmoi() {
  if ! has_command chezmoi; then
    warn_check "Chezmoi" "not installed; skipping chezmoi source check"
    return 0
  fi

  if (cd "$ROOT" && chezmoi managed >/dev/null); then
    pass_check "Chezmoi" "managed file list renders"
  else
    fail_check "Chezmoi" "could not render managed file list"
  fi
}

check_executable_permissions() {
  local file
  local checked=0
  local issues=0

  for file in "$ROOT"/scripts/*.sh; do
    [[ -f "$file" ]] || continue
    checked=$((checked + 1))
    if [[ ! -x "$file" ]]; then
      issues=$((issues + 1))
      warn_check "Executable bit" "$(relpath "$file") is not executable"
    fi
  done

  if [[ -d "$ROOT/dot_local/bin" ]]; then
    for file in "$ROOT"/dot_local/bin/executable_*; do
      [[ -f "$file" ]] || continue
      is_shell_script "$file" || continue
      checked=$((checked + 1))
      if [[ ! -x "$file" ]]; then
        issues=$((issues + 1))
        warn_check "Executable bit" "$(relpath "$file") is not executable"
      fi
    done
  fi

  if ((issues == 0)); then
    pass_check "Executable bit" "$checked runnable source script(s) checked"
  fi
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

  log_info "Dotfiles checks (read-only)"
  printf '\n'

  check_bash_syntax
  check_shellcheck
  check_shfmt
  check_secret_scan
  check_chezmoi
  check_executable_permissions

  printf '\n'
  if ((FAIL_COUNT > 0)); then
    log_error "Checks finished with $FAIL_COUNT failure(s) and $WARN_COUNT warning(s)."
    return 1
  fi

  log_info "Checks finished with no serious failures and $WARN_COUNT warning(s)."
}

main "$@"
