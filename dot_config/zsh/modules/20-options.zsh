# zsh/modules/20-options.zsh - shared zsh behavior.
#
# Options here should be safe on every machine and should not depend on optional
# tools. Tool-specific behavior belongs in modules/70-tools.zsh.

# Directory stack: make `cd -` and pushd workflows useful without duplicates.
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Globbing and completion ergonomics.
setopt EXTENDED_GLOB
setopt GLOB_DOTS
unsetopt CASE_GLOB

# History: keep timestamps, dedupe aggressively, and share between terminals.
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Safer interactive defaults.
setopt NO_CLOBBER
unsetopt BEEP

# Allow comments in interactive shell input, useful when pasting documented commands.
setopt INTERACTIVE_COMMENTS
