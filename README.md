# Dotfiles

Personal macOS dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Fresh macOS bootstrap

```zsh
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Install Git & Chezmoi
brew install git chezmoi

# 4. Initialize dotfiles AND install all software from Brewfile
DOTFILES_RUN_HOMEBREW_BUNDLE=1 chezmoi init --apply https://github.com/leonwong282/dotfiles.git
```

> **Note**: The `DOTFILES_RUN_HOMEBREW_BUNDLE=1` flag is required to trigger the automatic installation of all applications listed in the `Brewfile`. Without it, only configuration files will be applied.

After the first apply, restart the terminal so `.zprofile` and `.zshrc` are loaded from the managed files.

Then, follow the [Post-Setup Guide](docs/post-setup.md) to complete your manual configuration (secrets, SSH keys, etc.).

## Daily workflow

Preview changes before applying:

```zsh
chezmoi diff
```

Apply the repo state to `$HOME`:

```zsh
chezmoi apply
```

Edit a managed file:

```zsh
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
```

Import a local change back into the repo:

```zsh
chezmoi re-add ~/.zshrc
```

Commit and push:

```zsh
cd "$(chezmoi source-path)"
git status
git add .
git commit -m "Update dotfiles"
git push
```

## Scripts

This repo includes a small Scripts system for repo maintenance, environment
checks, conservative bootstrap help, and daily commands installed by chezmoi.

Start with:

```zsh
scripts/doctor.sh
scripts/check.sh
scripts/format.sh --check
```

After `chezmoi apply`, daily commands are available from `~/.local/bin`, for
example:

```zsh
path-check
sys-info
dev-update --dry-run
backup-dotfiles --dry-run
```

See [docs/scripts-guide.md](docs/scripts-guide.md) for the practical guide.

## Zsh layout

Zsh is split by startup phase and responsibility:

```text
~/.zshenv                              always loaded; XDG and zsh dirs only
~/.zprofile                            login shell; early PATH bootstrap
~/.zshrc                               interactive shell module loader
~/.config/starship.toml                Starship prompt style
~/.config/zsh/lib/source.zsh           safe source helpers
~/.config/zsh/lib/guards.zsh           platform and command predicates
~/.config/zsh/lib/path.zsh             PATH helper functions
~/.config/zsh/modules/00-path.zsh      Homebrew and PATH
~/.config/zsh/modules/05-local.pre.zsh early local overrides
~/.config/zsh/modules/10-env.zsh       editor, locale, history, pager
~/.config/zsh/modules/20-options.zsh   zsh behavior
~/.config/zsh/modules/30-completion.zsh
~/.config/zsh/modules/40-keybindings.zsh
~/.config/zsh/modules/50-aliases.zsh
~/.config/zsh/modules/60-functions.zsh
~/.config/zsh/modules/70-tools.zsh     fzf, zoxide, direnv, rbenv, pnpm
~/.config/zsh/modules/80-prompt.zsh    Starship bootstrap and fallback prompt
~/.config/zsh/modules/90-plugins.zsh   autosuggestions and highlighting
~/.config/zsh/modules/95-secrets.zsh   local secrets loader
~/.config/zsh/modules/99-local.post.zsh final local overrides
~/.config/zsh/examples/                copyable local/secrets examples
```

Load order in `.zshrc`:

```text
00-path
05-local.pre
10-env
20-options
30-completion
40-keybindings
50-aliases
60-functions
70-tools
80-prompt
90-plugins
95-secrets
99-local.post
```

Rules:

- Keep `.zshenv` tiny because it runs for scripts and non-interactive shells.
- Put shared interactive behavior in `~/.config/zsh/modules/*.zsh`.
- Put machine-only PATH and mirror settings in `~/.config/zsh/local.pre.zsh`.
- Put temporary aliases, functions, and experiments in `~/.config/zsh/local.post.zsh`.
- Put credentials only in `secrets.zsh` or an encrypted secret workflow.
- Set `ZSH_PROFILE=1` before launching an interactive shell to print zsh startup profiling.

## Secrets

Do not commit API keys, tokens, SSH private keys, or machine-specific credentials.

Interactive shell secrets are loaded from:

```zsh
~/.config/zsh/secrets.zsh
```

Machine-specific shell overrides are loaded from:

```zsh
~/.config/zsh/local.pre.zsh
~/.config/zsh/local.post.zsh
```

Use the managed examples under `~/.config/zsh/examples/` as templates and keep real local files untracked or encrypted.

## What belongs here

- Shell, Git, editor, SSH client, npm, and Homebrew configuration.
- Idempotent setup scripts for macOS defaults and package installation.
- Safe examples for secrets and local overrides.

Large files, project data, browser profiles, SSH private keys, and real application credentials should stay out of this repository.
