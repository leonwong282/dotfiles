# zsh/modules/80-prompt.zsh - prompt initialization.
#
# Starship owns visual prompt configuration through ~/.config/starship.toml.
# This module only selects Starship when installed and keeps a no-dependency
# fallback for the first bootstrap.

if zsh_has starship; then
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}"
    eval "$(starship init zsh)"
else
    autoload -Uz vcs_info
    zstyle ':vcs_info:git:*' formats ' git:%b'

    precmd() { vcs_info }
    PROMPT='%F{blue}%~%f%F{green}${vcs_info_msg_0_}%f %# '
fi
