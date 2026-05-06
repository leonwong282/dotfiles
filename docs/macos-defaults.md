# macOS Defaults Guide

This guide explains how to manage macOS system preferences (defaults) using the scripts provided in this repository.

The design goal of this system is **explicit control**. Unlike many dotfiles projects, `chezmoi apply` does not silently modify your macOS system settings by default. Instead, you manage these settings manually or through an opt-in lifecycle script.

## Core Scripts

- `scripts/macos/defaults.sh`: The primary script to inspect and apply settings.
- `scripts/macos/export-defaults.sh`: A diagnostic tool to read your *current* system values for the managed settings.

## Recommended Workflow

It is highly recommended to follow this "review-first" flow to avoid surprises:

### 1. Export Current Settings
Before making any changes, export your current system values to a file for comparison:
```zsh
scripts/macos/export-defaults.sh --all --output tmp/defaults-before.txt
```

### 2. List Managed Settings
View all the settings that this repository can manage, categorized by subsystem:
```zsh
scripts/macos/defaults.sh --list
```

### 3. Preview Changes (Dry Run)
See exactly what `defaults write` commands would be executed:
```zsh
scripts/macos/defaults.sh --dry-run
# Or for a specific category:
scripts/macos/defaults.sh --category finder --dry-run
```

### 4. Apply Settings
Apply the settings for a specific category after reviewing the dry run:
```zsh
scripts/macos/defaults.sh --category finder --apply
```

## Available Categories

- `global`: System-wide settings (file extensions, expanded save panels, text auto-correction).
- `finder`: Finder preferences (path bar, status bar, default search scope, POSIX paths in titles).
- `dock`: Dock behavior (icon size, magnification, minimize effect, hidden recents).
- `screenshots`: Screenshot management (storage location, file format, shadow removal).
- `keyboard`: Key repeat rates and auto-correction.

## Safety Principles

To prevent accidental system instability, these scripts:
- **Never use `sudo`** for `defaults write` (with very rare, explicit exceptions in lifecycle scripts).
- **Never modify** privacy, security, network, or power settings.
- **Never reset** your Dock content or Launchpad layout.
- **Support --dry-run** for every state-changing action.
- **Require confirmation** before applying any changes.

## Chezmoi Lifecycle Integration

The script `run_onchange_after_20-macos-defaults.sh.tmpl` allows you to opt-in to macOS defaults management during `chezmoi apply`.

When running `chezmoi apply`, it will:
1. Detect if it's an interactive terminal.
2. Ask for your confirmation: `Do you want to apply macOS system preferences?`.
3. If confirmed, run `scripts/macos/defaults.sh --apply` to sync your system state with the repository definitions.

To skip the interactive prompt and force a run (useful for automation), set the environment variable:
```zsh
DOTFILES_RUN_MACOS_DEFAULTS=1 chezmoi apply
```

## Adding New Settings

To manage a new macOS setting:
1. Find the domain and key using `defaults read`.
2. Add a new line to the `actions()` function in `scripts/macos/defaults.sh` using the pipe-separated format:
   `category|description|domain|key|type|value|restart_process|risk_level`
3. Verify it appears in `scripts/macos/defaults.sh --list`.
