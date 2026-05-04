# zsh/modules/70-tools.zsh - optional tool initialization.
#
# Every integration is guarded so a fresh macOS install remains usable before
# Brewfile has finished. Put heavier or experimental integrations in local.post.

# fzf key bindings and completion installed by Homebrew.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    zsh_source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
    zsh_source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

# Smarter directory jumping. Use `z <query>` after zoxide is installed.
if zsh_has zoxide; then
    eval "$(zoxide init zsh)"
fi

# Per-project environment loading via .envrc.
if zsh_has direnv; then
    eval "$(direnv hook zsh)"
fi

# Ruby version management. rbenv init is small enough for interactive startup
# and keeps shims working consistently for Ruby projects.
if zsh_has rbenv; then
    eval "$(rbenv init - zsh)"
fi

# pnpm uses PNPM_HOME for globally installed package shims.
if zsh_has pnpm; then
    export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
    zsh_path_prepend "$PNPM_HOME"
fi
