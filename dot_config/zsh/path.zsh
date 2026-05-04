# PATH and toolchain bootstrap shared by login and interactive shells.

# Load Homebrew's environment from the standard install locations. Apple
# Silicon uses /opt/homebrew; Intel macOS typically uses /usr/local.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Use zsh's `path` array instead of string concatenation so entries are easier
# to read and de-duplicate.
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    $path
)

# Remove duplicate PATH entries while preserving the first occurrence.
typeset -U path
export PATH

# Homebrew mirrors for users in China Mainland. Enable in local.zsh if needed.
# export HOMEBREW_PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
# export HOMEBREW_API_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
# export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
