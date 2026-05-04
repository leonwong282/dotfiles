# zsh/modules/90-plugins.zsh - lightweight zsh plugins.
#
# Plugins are sourced late so aliases, completion, and prompt are already set.
# Syntax highlighting should stay last among plugins because it wraps ZLE.

if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    zsh_source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    zsh_source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
