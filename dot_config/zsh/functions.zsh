# Shared shell functions.

mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [[ ! -f "$1" ]]; then
        echo "File not found: $1" >&2
        return 1
    fi

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
