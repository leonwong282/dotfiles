# Post-Setup Guide (Manual Configuration)

After running `chezmoi apply`, there are several manual steps required to fully personalize your environment and ensure security. These steps involve files and settings that are intentionally omitted from the repository (e.g., secrets, local overrides, and machine-specific keys).

## 1. Local Shell Overrides

The Zsh configuration is modular and supports local overrides that are not tracked by Git. Use these to set machine-specific PATHs, mirrors, or aliases.

Templates are located in `~/.config/zsh/examples/`.

### Secrets (`secrets.zsh`)
Used for API keys, tokens, and sensitive endpoints.
```zsh
cp ~/.config/zsh/examples/private_secrets.zsh.example ~/.config/zsh/secrets.zsh
chmod 600 ~/.config/zsh/secrets.zsh
# Edit the file to add your real keys
vim ~/.config/zsh/secrets.zsh
```

### Early Overrides (`local.pre.zsh`)
Used for settings needed *before* the main modules load, such as Homebrew mirrors or work-specific PATH additions.
```zsh
cp ~/.config/zsh/examples/local.pre.zsh.example ~/.config/zsh/local.pre.zsh
vim ~/.config/zsh/local.pre.zsh
```

### Late Overrides (`local.post.zsh`)
Used for host-specific aliases or experimental functions that should override shared defaults.
```zsh
cp ~/.config/zsh/examples/local.post.zsh.example ~/.config/zsh/local.post.zsh
vim ~/.config/zsh/local.post.zsh
```

---

## 2. SSH Keys

You need to generate a new SSH key for secure communication with GitHub and other servers.

1.  **Generate a new Ed25519 key**:
    ```zsh
    ssh-keygen -t ed25519 -C "your_email@example.com"
    ```
2.  **Add to the SSH Agent**:
    ```zsh
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    ```
3.  **Add to GitHub**:
    Copy your public key and add it to your [GitHub SSH settings](https://github.com/settings/keys).
    ```zsh
    pbcopy < ~/.ssh/id_ed25519.pub
    ```

---

## 3. Git Identity

The default `~/.gitconfig` contains placeholder identity details. You should set your local identity:

```zsh
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

*Note: If you use different identities for work and personal projects, consider using Git's `includeIf` feature in a local override.*

---

## 4. Application-Specific Setup

### VS Code
If extensions didn't sync automatically, or you need to sign in:
- Sign in to **Settings Sync** using your GitHub/Microsoft account.
- Check the `Brewfile` for a list of installed Casks and VS Code extensions if you need to install them manually.

### Mac App Store (MAS)
The `Brewfile` includes Mac App Store apps like Xcode. You must be signed in to the App Store for `mas` to install or update these:
```zsh
mas signin your_email@example.com
```

---

## 5. Environment Variables (.env)

For development projects, you likely have `.env` files that are ignored by Git.
- Use `direnv` (installed via Homebrew) to manage these per directory.
- Create a `.envrc` file in your project root:
  ```zsh
  echo "export API_KEY=your_value" > .envrc
  direnv allow
  ```

---

## 6. Restart & Verify

After completing the manual setup:
1.  **Restart your terminal** or run `exec zsh`.
2.  Run the health check to verify everything is in order:
    ```zsh
    scripts/doctor.sh
    path-check
    sys-info
    ```
