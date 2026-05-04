# zsh/modules/30-completion.zsh - completion system setup.
#
# Completion is often the slowest part of zsh startup. This module keeps
# generated state in XDG cache and uses `compinit -C` when the cache is fresh.

autoload -Uz compinit
zmodload zsh/datetime 2>/dev/null || true
zmodload -F zsh/stat b:zstat 2>/dev/null || true

# Add Homebrew-provided completions before compinit scans fpath.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    fpath=(
        "$HOMEBREW_PREFIX/share/zsh/site-functions"
        "$HOMEBREW_PREFIX/share/zsh-completions"
        $fpath
    )
    typeset -gU fpath
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'

mkdir -p "${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"

typeset zcompdump="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/zcompdump-${ZSH_VERSION}"
typeset -a zcompdump_stat
typeset zcompdump_mtime=0
typeset zcompdump_ttl=86400

if [[ -s "$zcompdump" ]] && (( $+builtins[zstat] )); then
    zstat -A zcompdump_stat +mtime "$zcompdump" 2>/dev/null || zcompdump_stat=(0)
    zcompdump_mtime="${zcompdump_stat[1]:-0}"
fi

# Use the fast path for one day. `-i` ignores insecure completion directories
# instead of prompting, which keeps automated shells and chezmoi checks from
# hanging or aborting when no TTY is attached.
if [[ -s "$zcompdump" ]] && (( ${EPOCHSECONDS:-0} - zcompdump_mtime < zcompdump_ttl )); then
    compinit -C -i -d "$zcompdump"
else
    compinit -i -d "$zcompdump"
fi

unset zcompdump zcompdump_stat zcompdump_mtime zcompdump_ttl
