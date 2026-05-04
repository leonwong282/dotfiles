# Prompt setup.

# Prefer Starship when installed because it provides a consistent prompt across
# shells and machines.
if command -v starship >/dev/null 2>&1; then
    # Starship reads ~/.config/starship.toml by default. STARSHIP_CONFIG remains
    # overridable from local.zsh for machine-specific experiments.
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}"
    eval "$(starship init zsh)"
else
    # Lightweight fallback: show current directory and Git branch without any
    # external dependency.
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats ' %F{green}(%b)%f'
    PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %# '
fi
