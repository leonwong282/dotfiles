# zsh/modules/05-local.pre.zsh - machine-specific early overrides.
#
# Use this layer for PATH, Homebrew mirrors, or environment values that must be
# visible before completion, aliases, and tool initialization.

zsh_source "local.pre.zsh"
zsh_source_dir "local.pre.d"
