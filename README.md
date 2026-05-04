# Dotfiles

Personal macOS dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Fresh macOS bootstrap

```zsh
xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install git chezmoi
chezmoi init --apply https://github.com/leonwong282/dotfiles.git
```

After the first apply, restart the terminal so `.zprofile` and `.zshrc` are loaded from the managed files.

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

## Secrets

Do not commit API keys, tokens, SSH private keys, or machine-specific credentials.

Interactive shell secrets are loaded from:

```zsh
~/.config/zsh/secrets.zsh
```

Machine-specific shell overrides are loaded from:

```zsh
~/.config/zsh/local.zsh
```

Use the managed `~/.config/zsh/secrets.zsh.example` as a template and keep the real `secrets.zsh` local or encrypted.

## What belongs here

- Shell, Git, editor, SSH client, npm, and Homebrew configuration.
- Idempotent setup scripts for macOS defaults and package installation.
- Safe examples for secrets and local overrides.

Large files, project data, browser profiles, SSH private keys, and real application credentials should stay out of this repository.
