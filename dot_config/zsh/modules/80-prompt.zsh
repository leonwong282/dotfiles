# zsh/modules/80-prompt.zsh - prompt initialization.
#
# Starship owns visual prompt configuration through ~/.config/starship.toml.
# This module only selects Starship when installed and keeps a no-dependency
# fallback for the first bootstrap.

if zsh_has starship; then
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}"
    # PERF: `starship init` executes the starship binary at startup and installs
    # prompt hooks. Keep STARSHIP_CONFIG lean and use `starship timings` if a
    # prompt render becomes slow inside large repos.
    eval "$(starship init zsh)"
else
    autoload -Uz vcs_info
    zstyle ':vcs_info:git:*' formats ' git:%b'

    # PERF: vcs_info runs before every prompt. It is a fallback only; Starship
    # should be preferred on the main macOS setup.
    precmd() { vcs_info }
    PROMPT='%F{blue}%~%f%F{green}${vcs_info_msg_0_}%f %# '
fi
