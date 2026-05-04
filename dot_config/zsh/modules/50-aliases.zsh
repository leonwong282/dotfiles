# zsh/modules/50-aliases.zsh - shared aliases.
#
# Aliases should improve interactive work without making pasted shell snippets
# surprising. Prefer explicit modern-tool aliases over replacing core commands.

# Directory navigation shortcuts.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Listing shortcuts. `ls` may use eza when available, but `command ls` remains
# available for POSIX behavior.
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

if zsh_has eza; then
    # PERF: zsh_has uses command lookup. A handful of checks is acceptable, but
    # avoid growing aliases.zsh into dozens of command probes.
    alias ls='eza'
    alias ll='eza -la --group-directories-first --git'
    alias la='eza -a --group-directories-first'
    alias tree='eza --tree'
fi

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

# Explicit modern-tool shortcuts.
# PERF: these command checks are tiny compared with compinit/tool hooks; keep
# them guarded so fresh machines do not emit errors.
zsh_has bat && alias batp='bat --paging=always'
zsh_has fd && alias ff='fd'
zsh_has rg && alias rgrep='rg'

# Small utility aliases for daily shell work.
alias path='print -l $path'
alias myip='curl ifconfig.me'
alias c='clear'
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-vim} ~/.zshrc'
