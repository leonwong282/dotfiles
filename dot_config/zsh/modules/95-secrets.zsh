# zsh/modules/95-secrets.zsh - local secrets loader.
#
# The real secrets.zsh file is intentionally not managed by this repository.
# Keep API keys, tokens, and passwords local or move them to encrypted chezmoi
# templates later.

zsh_source "secrets.zsh"
# PERF: secrets.d is optional. Keep files here small and avoid commands that
# contact password managers or the network during every shell startup.
zsh_source_dir "secrets.d"
