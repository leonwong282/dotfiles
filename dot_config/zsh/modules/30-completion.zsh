# zsh/modules/30-completion.zsh - completion system setup.
#
# Completion is often the slowest part of zsh startup. This module keeps
# generated state in XDG cache and uses `compinit -C` when the cache is fresh.

# PERF: compinit/compaudit dominate zsh startup on many machines. This module
# caches zcompdump and uses the -C fast path for one day.
autoload -Uz compinit
zmodload zsh/datetime 2>/dev/null || true
zmodload -F zsh/stat b:zstat 2>/dev/null || true

# Add Homebrew-provided completions before compinit scans fpath.
# git, gh, brew, docker-completion, starship, rbenv, and many Homebrew formulae
# install _command files here. npm is usually supplied by the system zsh
# functions or zsh-completions when installed.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    typeset -a zsh_completion_dirs

    [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]] && zsh_completion_dirs+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
    [[ -d "$HOMEBREW_PREFIX/share/zsh-completions" ]] && zsh_completion_dirs+=("$HOMEBREW_PREFIX/share/zsh-completions")

    fpath=($zsh_completion_dirs $fpath)
    typeset -gU fpath
    unset zsh_completion_dirs
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'

# PERF: one mkdir per startup. It is intentionally kept because compinit needs
# a writable zcompdump location on first bootstrap.
mkdir -p "${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"

typeset zcompdump="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/zcompdump-${ZSH_VERSION}"
typeset -a zcompdump_stat
typeset zcompdump_mtime=0
typeset zcompdump_ttl=86400

if [[ -s "$zcompdump" ]] && (( $+builtins[zstat] )); then
    # PERF: zstat is cheaper than a full compaudit run and lets us decide
    # whether the cached zcompdump is still fresh.
    zstat -A zcompdump_stat +mtime "$zcompdump" 2>/dev/null || zcompdump_stat=(0)
    zcompdump_mtime="${zcompdump_stat[1]:-0}"
fi

# Use the fast path for one day. `-i` ignores insecure completion directories
# instead of prompting, which keeps automated shells and chezmoi checks from
# hanging or aborting when no TTY is attached.
if [[ -s "$zcompdump" ]] && (( ${EPOCHSECONDS:-0} - zcompdump_mtime < zcompdump_ttl )); then
    compinit -C -i -d "$zcompdump"
else
    # PERF: full compinit audits fpath and should only run when cache is absent
    # or stale. If startup gets slow, inspect this path first with zprof.
    compinit -i -d "$zcompdump"
fi

unset zcompdump zcompdump_stat zcompdump_mtime zcompdump_ttl
