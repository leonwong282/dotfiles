# zsh/lib/guards.zsh - small predicates used by zsh modules.
#
# Keep these helpers fast and dependency-free. They make platform and command
# checks readable without scattering test expressions across modules.

zsh_has() {
    command -v "$1" >/dev/null 2>&1
}

zsh_is_macos() {
    # PERF: `uname` is external on macOS. This helper is fine for occasional
    # module guards, but avoid calling it in prompt hooks or tight loops.
    [[ "$(uname -s 2>/dev/null)" == "Darwin" ]]
}

zsh_is_apple_silicon() {
    # PERF: same as zsh_is_macos; cache this in a variable if it becomes hot.
    [[ "$(uname -m 2>/dev/null)" == "arm64" ]]
}
