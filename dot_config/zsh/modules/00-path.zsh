# zsh/modules/00-path.zsh - Homebrew and PATH setup.
#
# This module is sourced by both ~/.zprofile and ~/.zshrc. The guard below makes
# it idempotent in login interactive shells where both files run in one process.

[[ -n "${__ZSH_PATH_LOADED:-}" ]] && return 0
typeset -g __ZSH_PATH_LOADED=1

zsh_load_homebrew

# Homebrew completions and command directories should be visible before
# completion initializes and before aliases test for modern tools.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    zsh_path_prepend "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
fi

# User-local toolchains for macOS development. Only existing directories are
# added, so a fresh machine stays clean until tools are installed.
zsh_path_prepend \
    "$HOME/bin" \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/go/bin" \
    "$HOME/Library/pnpm"

# Homebrew mirrors are intentionally left to local.pre.zsh because mirror choice
# depends on the current network location.
