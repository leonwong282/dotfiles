# General interactive shell environment.

# Respect values already provided by the OS, terminal, or local.zsh.
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-code --wait}"

# Keep locale explicit so CLI tools render Unicode and sort consistently.
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Store history in the default zsh location with a large but bounded size.
export HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
export HISTSIZE="${HISTSIZE:-10000}"
export SAVEHIST="${SAVEHIST:-10000}"

# Preserve color escape sequences when paging command output.
export LESS="${LESS:--R}"
export PAGER="${PAGER:-less}"
