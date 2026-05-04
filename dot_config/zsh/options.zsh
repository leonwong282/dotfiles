# Zsh behavior that is safe to share across machines.

# Directory stack: `cd -` and pushd workflows become more useful without
# keeping duplicate entries.
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# History: keep timestamps, reduce duplicates, and share commands between
# terminal sessions.
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Avoid terminal bell noise when completion or editing hits an edge.
unsetopt BEEP

# Emacs keybindings are the zsh default on many systems and work well in plain
# terminals without extra setup.
bindkey -e
