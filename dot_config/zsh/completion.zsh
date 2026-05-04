# Completion setup.

# Load zsh's built-in completion system.
autoload -Uz compinit

# Show a selectable menu, match case-insensitively, and reuse LS_COLORS when it
# is available.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Keep zcompdump under XDG cache so generated completion state is not tracked
# with dotfiles.
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
