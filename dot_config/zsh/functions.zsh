# Shared shell functions.

# Create a directory and move into it in one step.
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract common archive formats without remembering tar/unzip flags.
extract() {
    if [[ ! -f "$1" ]]; then
        echo "File not found: $1" >&2
        return 1
    fi

    # Dispatch by filename extension; unknown formats return non-zero so
    # scripts or chained commands can detect the failure.
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.xz)  tar xJf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.7z)      7z x "$1" ;;
        *)         echo "Unknown archive format: $1" >&2; return 1 ;;
    esac
}
