# Brewfile
# Target: Apple Silicon M1 MacBook Air, macOS Sequoia
# Usage:
#   HOMEBREW_BUNDLE_NO_UPGRADE=1 brew bundle --file Brewfile
#
# Notes:
# - Keep versioned databases/runtimes pinned only when project compatibility needs it.
# - GUI apps and experimental AI tools are separated from core CLI tools.
# - `homebrew/cask-fonts` is intentionally omitted because fonts now live in homebrew/cask.

# ====================
# Global Cask Settings
# ====================
cask_args appdir: "/Applications"

# ====================
# Taps
# ====================
tap "stripe/stripe-cli" # Official Stripe CLI tap

# ====================
# Bootstrap & Package Management
# ====================
brew "chezmoi"          # Dotfiles manager
brew "mas"              # Mac App Store CLI
brew "gh"               # GitHub CLI

# ====================
# Shell & Core CLI
# ====================
brew "git"              # Distributed version control
brew "zsh"              # Z shell
brew "curl"             # Tool for transferring data via URLs
brew "wget"             # Network file downloader
brew "jq"               # Command-line JSON processor
brew "tree"             # Display directory tree
brew "htop"             # Interactive process viewer

# ====================
# Modern Unix Utilities
# ====================
brew "bat"              # cat clone with syntax highlighting
brew "eza"              # Modern replacement for ls
brew "fd"               # Simple and fast alternative to find
brew "ripgrep"          # Fast line-oriented search tool (rg)
brew "fzf"              # Command-line fuzzy finder
brew "zoxide"           # Smarter cd command
brew "direnv"           # Load/unload environment variables per directory
brew "starship"         # Cross-shell prompt
brew "age"              # Modern file encryption tool

# ====================
# Zsh Enhancements
# ====================
brew "zsh-autosuggestions"     # Fish-like autosuggestions for Zsh
brew "zsh-syntax-highlighting" # Fish-like syntax highlighting for Zsh
brew "zsh-completions"         # Additional completion definitions for Zsh

# ====================
# Editors
# ====================
# brew "neovim"           # Hyperextensible Vim-based text editor
brew "vim"              # Vi Improved text editor

# ====================
# Language Runtimes & Version Managers
# ====================
brew "node"             # JavaScript runtime built on Chrome's V8
brew "pnpm"             # Fast, disk space efficient package manager for Node.js
brew "python@3.12"      # Python programming language (v3.12)
brew "uv"               # Extremely fast Python package manager
brew "go"               # Go programming language compiler
brew "rustup"           # Rust toolchain installer
brew "rbenv"            # Ruby version manager
brew "ruby"             # Ruby programming language
brew "openjdk@11"       # Java Development Kit (v11)
brew "qt"               # Cross-platform application framework

# ====================
# Apple / Mobile Development
# ====================
brew "cocoapods"        # Dependency manager for Cocoa projects

# ====================
# Cloud & Deployment CLIs
# ====================
brew "awscli"           # AWS command-line interface
brew "cloudflare-wrangler" # Cloudflare Workers CLI
brew "vercel-cli"       # Vercel deployment CLI
brew "stripe/stripe-cli/stripe" # Stripe payment platform CLI
brew "gemini-cli"       # Google Gemini AI CLI

# ====================
# Containers
# ====================
brew "docker"           # Docker container engine CLI
brew "docker-compose"   # Tool for defining multi-container apps
brew "docker-buildx"    # Docker CLI plugin for extended builds
brew "docker-completion" # Zsh completion for Docker

# ====================
# Databases & Local Services
# ====================
brew "postgresql@17", restart_service: :changed # Object-relational database system (v17)
brew "redis", restart_service: :changed          # In-memory data structure store
brew "mariadb"          # Community-developed fork of MySQL

# ====================
# Useful CLI Tools
# ====================
brew "yt-dlp"           # YouTube/media downloader
brew "ffmpeg"           # Multimedia framework for audio/video processing
brew "imagemagick"      # Image manipulation tool
brew "pandoc"           # Universal document converter
brew "tldr"             # Simplified and community help
brew "cliproxyapi"      # Clipboard manager with API access

# ====================
# Development Applications
# ====================
cask "visual-studio-code" # Code editor refined for building web/cloud apps
cask "warp"             # Modern Rust-based terminal
cask "termius"          # SSH client and terminal
cask "pycharm"          # Python IDE for professional developers
cask "clion"            # C and C++ IDE
cask "antigravity"      # AI-powered development tool
cask "claude-code"      # Interactive CLI for Claude
cask "codex-app"        # AI code generation companion
cask "qt-creator"       # Integrated development environment for Qt
# cask "mactex-no-gui"    # TeX distribution for macOS (minimal)
cask "docker-desktop"  # GUI for managing Docker containers and images

# ====================
# Browsers
# ====================
cask "google-chrome"    # Web browser from Google
cask "comet"            # Modern web browser
cask "thebrowsercompany-dia" # Arc browser utility
cask "chatgpt-atlas"    # ChatGPT desktop enhancement

# ====================
# Productivity & Communication
# ====================
cask "slack"            # Team communication platform
cask "notion"           # All-in-one workspace for notes/tasks
cask "notion-mail"      # Email client from Notion
cask "notion-calendar"  # Calendar app from Notion
cask "chatgpt"          # Official ChatGPT desktop app
cask "google-gemini"    # Official Google Gemini desktop app
cask "claude"           # Official Claude desktop app
cask "telegram-desktop" # Desktop client for Telegram messenger
cask "google-drive"     # Cloud storage and collaboration
cask "baidunetdisk"     # Baidu Cloud storage client
cask "wpsoffice-cn"     # All-in-one office suite (Chinese version)
cask "snipaste"         # Snipping and pinning tool
cask "easydict"         # Dictionary and translation app
cask "anki"             # Flashcard learning with spaced repetition
cask "zotero"           # Reference management tool for research
cask "simpletex"        # LaTeX OCR and formula recognition
cask "macwhisper"       # High-quality AI transcription locally

# ====================
# System Utilities
# ====================
cask "raycast"          # Extendable launcher and productivity tool
cask "stats"            # macOS system monitor in menu bar
cask "alt-tab"          # Windows-like Alt-Tab switcher for macOS
cask "maczip"           # Archiver and unarchiver for macOS
cask "pearcleaner"      # Open-source app uninstaller

# ====================
# Design & Media
# ====================
cask "ogdesign-eagle"   # Digital asset management tool
cask "spotify"          # Digital music service
cask "iina"             # Modern media player for macOS
cask "licecap"          # Simple animated screen capture (GIF)

# ====================
# Fonts
# ====================
cask "font-fira-code"   # Monospaced font with programming ligatures
cask "font-jetbrains-mono" # Free and open-source typeface for developers

# ====================
# Mac App Store
# ====================
mas "Xcode", id: 497799835 # Apple's IDE for macOS/iOS development
