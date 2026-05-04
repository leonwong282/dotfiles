# zsh/modules/40-keybindings.zsh - interactive key bindings.
#
# Keep bindings here rather than mixed into options or tools so editing behavior
# has one obvious place to evolve.

bindkey -e

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Make Up/Down search through history entries that match the current prefix.
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Keep Ctrl-R useful even before fzf key bindings are installed.
bindkey '^R' history-incremental-search-backward
