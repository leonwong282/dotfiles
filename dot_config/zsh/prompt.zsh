# Prompt setup.

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats ' %F{green}(%b)%f'
    PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %# '
fi
