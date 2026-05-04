# Scripts Guide

This repository has a small Scripts system for maintaining the dotfiles repo,
checking the local development environment, bootstrapping a new machine
conservatively, and installing daily helper commands through chezmoi.

The design goal is explicit control. `chezmoi apply` should apply dotfiles, not
silently install packages, clean files, or rewrite system preferences.

## Structure

```text
scripts/                         repository maintenance scripts
scripts/lib/                     shared helpers for repository scripts
dot_local/bin/executable_*       daily commands installed into ~/.local/bin
run_*                            optional chezmoi lifecycle scripts
```

Chezmoi maps source names to target names. For example:

```text
dot_local/bin/executable_dev-update
```

becomes:

```text
~/.local/bin/dev-update
```

The `executable_` prefix means chezmoi should install the target with executable
permissions.

## Script Types

Repository maintenance scripts live under `scripts/`. Run them from the chezmoi
source directory:

```zsh
cd "$(chezmoi source-path)"
scripts/check.sh
```

Daily commands live under `dot_local/bin/executable_*` and are installed into
`~/.local/bin` after `chezmoi apply`. They should not depend on repo-only files
such as `scripts/lib/common.sh`.

Chezmoi lifecycle scripts use `run_*` names. They should be rare, obvious, and
safe. State-changing lifecycle scripts in this repo are opt-in through explicit
environment variables.

## Available Commands

| Command | Purpose | State |
| --- | --- | --- |
| `scripts/doctor.sh` | Health check for OS, shell, tools, PATH, and chezmoi source shape. | Read-only |
| `scripts/check.sh` | Repo checks: Bash syntax, optional ShellCheck/shfmt, lightweight secret scan, chezmoi render check. | Read-only |
| `scripts/format.sh --check` | Check shell formatting with `shfmt`. | Read-only |
| `scripts/format.sh --write` | Rewrite shell scripts with `shfmt`. | Modifies repo files |
| `scripts/bootstrap.sh` | Conservative bootstrap helper. Default mode prints checks and next steps. | Read-only by default |
| `scripts/bootstrap.sh --dry-run` | Runs read-only checks plus `chezmoi apply --dry-run`. | Read-only |
| `scripts/bootstrap.sh --apply` | Runs `chezmoi apply` after confirmation. | Modifies home files |
| `dev-update` | Manual update helper for Homebrew and chezmoi source review. | Modifies system/repo state |
| `path-check` | PATH diagnostics and command lookup report. | Read-only |
| `backup-dotfiles` | Local snapshot of selected dotfiles. | Writes backup files |
| `sys-info` | Concise system and tool version report. | Read-only |

## Dry Run Support

Use dry-run before running state-changing commands:

```zsh
scripts/bootstrap.sh --dry-run
dev-update --dry-run
backup-dotfiles --dry-run
```

`scripts/format.sh` defaults to check mode. Use `--write` only when you want it
to edit files.

## New Machine Flow

On a fresh macOS machine, install the minimum tools manually first:

```zsh
xcode-select --install
brew install git chezmoi
chezmoi init https://github.com/leonwong282/dotfiles.git
```

Then inspect before applying:

```zsh
cd "$(chezmoi source-path)"
scripts/bootstrap.sh
scripts/bootstrap.sh --dry-run
chezmoi diff
```

Apply only after review:

```zsh
scripts/bootstrap.sh --apply
```

Restart the terminal after the first apply so the managed zsh files and PATH are
loaded.

## Routine Maintenance Flow

Use this flow for normal upkeep:

```zsh
cd "$(chezmoi source-path)"
scripts/doctor.sh
scripts/check.sh
scripts/format.sh --check
chezmoi diff
```

For daily system updates:

```zsh
dev-update --dry-run
dev-update
```

`dev-update` does not run `chezmoi apply`, commit, or push. It also skips
`brew cleanup` unless `--cleanup` is passed.

## Testing Daily Commands

After `chezmoi apply`, open a new shell or reload PATH, then run:

```zsh
command -v dev-update
command -v path-check
command -v backup-dotfiles
command -v sys-info

path-check
sys-info
dev-update --dry-run
backup-dotfiles --dry-run
```

## Lifecycle Scripts

Lifecycle scripts should not make `chezmoi apply` surprising. The current
state-changing lifecycle scripts are skipped by default:

```zsh
DOTFILES_RUN_HOMEBREW_BUNDLE=1 chezmoi apply
DOTFILES_RUN_MACOS_DEFAULTS=1 chezmoi apply
```

Use those only when you explicitly want package reconciliation or macOS defaults
changes during apply. Prefer manual scripts for package updates, backups,
bootstrap work, and environment checks.

## Safety Principles

- No destructive default behavior.
- No silent system modifications.
- No silent package installation.
- No auto-commit or auto-push.
- No automatic `chezmoi apply` without confirmation.
- Clear output for skipped, warned, and failed steps.
- Dry-run support for useful state-changing workflows.
