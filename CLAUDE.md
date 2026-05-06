# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- **Preview changes**: `chezmoi diff`
- **Apply changes**: `chezmoi apply`
- **Edit managed file**: `chezmoi edit <file>` (e.g., `chezmoi edit ~/.zshrc`)
- **Add unmanaged file**: `chezmoi add <file>`
- **Re-add modified file**: `chezmoi re-add <file>`
- **Check repo health**: `scripts/doctor.sh`
- **Run lint/checks**: `scripts/check.sh`
- **Check shell formatting**: `scripts/format.sh --check`
- **Fix shell formatting**: `scripts/format.sh --write`

## Architecture and Structure

- **Dotfiles Manager**: This repository uses [chezmoi](https://www.chezmoi.io/) to manage dotfiles.
- **Zsh Layout**: The Zsh configuration is highly modularized under `~/.config/zsh/`.
  - `~/.zshenv`: Always loaded; keep tiny. Only XDG and zsh dirs.
  - `~/.zprofile`: Login shell; early PATH bootstrap.
  - `~/.zshrc`: Interactive shell module loader. Loads modules from `~/.config/zsh/modules/*.zsh` in a numbered order.
  - Local overrides go in `~/.config/zsh/local.pre.zsh` and `~/.config/zsh/local.post.zsh`.
  - Interactive shell secrets go in `~/.config/zsh/secrets.zsh`.
- **Scripts System**: A collection of scripts for repo maintenance and macOS configuration.
  - `scripts/`: Repository maintenance scripts (`doctor.sh`, `check.sh`, `format.sh`, `bootstrap.sh`). Run these from the chezmoi source directory (`$(chezmoi source-path)`).
  - `dot_local/bin/executable_*`: Daily commands that are installed to `~/.local/bin` after a `chezmoi apply` (e.g., `dev-update`, `path-check`, `sys-info`). These should not depend on repo-only files.
  - `scripts/macos/defaults.sh`: Script to manage macOS defaults manually, categorized by subsystem. Use `--dry-run` to preview and `--apply` to apply.
  - `run_*`: Chezmoi lifecycle scripts. The Homebrew bundle script (`run_onchange_after_10-homebrew-bundle.sh.tmpl`) is opt-in and requires setting `DOTFILES_RUN_HOMEBREW_BUNDLE=1` before `chezmoi apply`.

## Workflow Guidelines

- **Explicit Control**: The design goal of this repository is explicit control. `chezmoi apply` should only apply dotfiles, not silently install packages, clean files, or rewrite system preferences without explicit opt-in (like the `DOTFILES_RUN_HOMEBREW_BUNDLE` environment variable).
- **Dry-run First**: Use `--dry-run` before running state-changing commands (`scripts/bootstrap.sh`, `scripts/macos/defaults.sh`, `dev-update`, `backup-dotfiles`).
- **Committing**: Changes should be committed from the `chezmoi source-path` directory.
- **Secrets**: Do not commit API keys, tokens, SSH private keys, or machine-specific credentials. Use the examples under `~/.config/zsh/examples/` as templates. Keep real local files untracked or encrypted. Large files, browser profiles, and real application credentials should also stay out of the repository.
