# zsh/modules/95-secrets.zsh - local secrets loader.
#
# The real secrets.zsh file is intentionally not managed by this repository.
# Keep API keys, tokens, and passwords local or move them to encrypted chezmoi
# templates later.

zsh_source "secrets.zsh"
zsh_source_dir "secrets.d"
