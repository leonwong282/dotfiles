# zsh/modules/99-local.post.zsh - final machine-specific overrides.
#
# Use this layer for host-only aliases, temporary experiments, or overrides that
# should win over shared modules. local.zsh is loaded for backward compatibility
# with the earlier layout.

zsh_source "local.post.zsh"
# PERF: local.post.d is an extension point. Large or slow experiments here will
# affect every shell, so profile them before keeping them permanently.
zsh_source_dir "local.post.d"
zsh_source "local.zsh"
