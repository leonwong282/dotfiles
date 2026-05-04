# zsh/lib/source.zsh - shared module-loading helpers.
#
# The entrypoints ~/.zprofile and ~/.zshrc source this file first. Helpers are
# intentionally namespaced with `zsh_` so they can safely remain available for
# local overrides and future modules.

: "${ZSH_CONFIG_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"

# Source a file relative to ZSH_CONFIG_DIR, or an absolute path, only when it is
# readable. Missing optional files should not break a fresh bootstrap.
zsh_source() {
    local file="$1"

    [[ "$file" == /* ]] || file="$ZSH_CONFIG_DIR/$file"
    [[ -r "$file" ]] && source "$file"
}

# Source every *.zsh file in a directory in lexical order. This gives local
# machines a clean extension point without editing managed modules.
zsh_source_dir() {
    local dir="$1"
    local file

    [[ "$dir" == /* ]] || dir="$ZSH_CONFIG_DIR/$dir"
    [[ -d "$dir" ]] || return 0

    for file in "$dir"/*.zsh(N); do
        source "$file"
    done
}
