# zsh/lib/path.zsh - PATH and Homebrew helper functions.
#
# PATH is configured from modules/00-path.zsh. These helpers keep the module
# readable and avoid duplicate string manipulation.

zsh_path_prepend() {
    local dir
    local -a entries

    for dir in "$@"; do
        [[ -d "$dir" ]] && entries+=("$dir")
    done

    path=($entries $path)
    typeset -gU path
    export PATH
}

zsh_path_append() {
    local dir
    local -a entries

    for dir in "$@"; do
        [[ -d "$dir" ]] && entries+=("$dir")
    done

    path=($path $entries)
    typeset -gU path
    export PATH
}

zsh_load_homebrew() {
    [[ -n "${__ZSH_HOMEBREW_LOADED:-}" ]] && return 0
    typeset -g __ZSH_HOMEBREW_LOADED=1

    # PERF: `brew shellenv` starts the Ruby/Homebrew executable. The guard above
    # prevents duplicate work when both .zprofile and .zshrc source PATH setup.
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}
