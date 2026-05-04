# zsh/modules/60-functions.zsh - shared shell functions.
#
# Keep functions small and dependency-light. Larger workflows belong in scripts
# under ~/bin or ~/.local/bin.

# Create a directory and move into it in one step.
mkcd() {
    [[ $# -eq 1 ]] || { print -u2 "usage: mkcd <directory>"; return 2; }
    mkdir -p "$1" && cd "$1"
}

# Alias-friendly name for mkcd.
take() {
    mkcd "$@"
}

# Extract common archive formats without remembering tar/unzip flags.
extract() {
    [[ $# -eq 1 ]] || { print -u2 "usage: extract <archive>"; return 2; }

    if [[ ! -f "$1" ]]; then
        print -u2 "extract: file not found: $1"
        return 1
    fi

    # Dispatch by filename extension; unknown formats return non-zero so
    # scripts or chained commands can detect the failure.
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz) tar xzf "$1" ;;
        *.tar.xz) tar xJf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.zip) unzip "$1" ;;
        *.7z) 7z x "$1" ;;
        *) print -u2 "extract: unknown archive format: $1"; return 1 ;;
    esac
}

# Print PATH one entry per line. This mirrors the `path` alias but is easier to
# use in pipelines.
path_entries() {
    print -l $path
}
