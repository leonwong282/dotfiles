# Shared aliases.

# Directory navigation shortcuts.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Compact listing shortcuts. These use `ls` first, then may be overridden by
# eza later if it is installed.
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Common Git commands with short, memorable names.
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# Interactive safety for destructive file operations.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Prefer modern CLI tools when they are installed, while keeping the shell
# usable on a fresh machine before Brewfile has completed.
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v eza >/dev/null 2>&1 && alias ls='eza'
command -v fd >/dev/null 2>&1 && alias find='fd'
command -v rg >/dev/null 2>&1 && alias grep='rg'

# Small utility aliases for daily shell work.
alias path='echo $PATH | tr ":" "\n"'
alias myip='curl ifconfig.me'
alias c='clear'
alias zshconfig='${EDITOR:-vim} ~/.zshrc'
alias reload='source ~/.zshrc'
