# zsh/modules/10-env.zsh - shared interactive shell environment.
#
# Values use defaults so the OS, terminal app, or local.pre.zsh can override
# them before this module runs.

export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-code --wait}"

# LANG is enough for most macOS tools. Avoid LC_ALL so category-specific locale
# values can still be changed by applications or local overrides.
export LANG="${LANG:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

# Store zsh history under XDG_STATE_HOME to keep generated state out of the repo
# and away from the top level of $HOME.
export HISTFILE="${HISTFILE:-${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history}"
export HISTSIZE="${HISTSIZE:-20000}"
export SAVEHIST="${SAVEHIST:-20000}"
mkdir -p "${HISTFILE:h}"

# Preserve ANSI colors in paged output.
export LESS="${LESS:--R}"
export PAGER="${PAGER:-less}"

# Starship writes session logs/cache; keep it under XDG cache.
export STARSHIP_CACHE="${STARSHIP_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/starship}"
