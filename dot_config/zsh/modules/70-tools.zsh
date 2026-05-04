# zsh/modules/70-tools.zsh - optional tool initialization.
#
# Every integration is guarded so a fresh macOS install remains usable before
# Brewfile has finished. Put heavier or experimental integrations in local.post.

# fzf key bindings and completion installed by Homebrew.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    # PERF: sourcing fzf shell scripts adds startup work. Keep this guarded and
    # move to local.post.zsh if a machine does not use fzf key bindings.
    zsh_source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
    zsh_source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

# Smarter directory jumping. Use `z <query>` after zoxide is installed.
if zsh_has zoxide; then
    # PERF: `zoxide init` executes an external command at startup. It is usually
    # fast, but can be replaced with a cached init snippet if needed.
    eval "$(zoxide init zsh)"
fi

# Per-project environment loading via .envrc.
if zsh_has direnv; then
    # PERF: `direnv hook` executes once at startup and then runs lightweight
    # hooks on directory changes.
    eval "$(direnv hook zsh)"
fi

# Ruby version management. rbenv init is small enough for interactive startup
# and keeps shims working consistently for Ruby projects.
if zsh_has rbenv; then
    # PERF: `rbenv init` is one of the more likely language-manager costs. If
    # startup regresses, consider lazy-loading rbenv per Ruby project.
    eval "$(rbenv init - zsh)"
fi

# pnpm uses PNPM_HOME for globally installed package shims.
if zsh_has pnpm; then
    # PERF: command lookup plus PATH de-duplication only; this is cheaper than
    # running a pnpm init command.
    export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
    zsh_path_prepend "$PNPM_HOME"
fi
