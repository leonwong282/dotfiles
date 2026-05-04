#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

# 增加交互式檢查，與 Homebrew 腳本一致
if [[ -t 0 || "${DOTFILES_RUN_MACOS_DEFAULTS:-0}" == "1" ]]; then
    echo "--------------------------------------------------------"
    echo "🖥️  macOS System Preferences Check"
    echo "--------------------------------------------------------"
else
    exit 0
fi

# 詢問使用者是否執行，避免靜默修改系統行為
if [[ "${DOTFILES_RUN_MACOS_DEFAULTS:-0}" != "1" ]]; then
    read -p "Do you want to apply macOS system preferences (Finder, Dock, Keyboard, etc.)? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping macOS preferences."
        exit 0
    fi
fi

osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true
osascript -e 'tell application "System Preferences" to quit' >/dev/null 2>&1 || true

echo "🚀 Configuring macOS preferences..."

# 請求 sudo 權限（如果尚未授權）
# 這會彈出一次密碼提示，之後的 sudo 指令將直接使用快取
if ! sudo -n true 2>/dev/null; then
    echo "🔐 Some settings (like boot sound) require admin privileges."
    sudo -v
fi

# 保持 sudo 權限直到腳本結束
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX
###############################################################################

# 現在可以放心地執行 sudo 命令了
sudo nvram SystemAudioVolume=" " || true

defaults write com.apple.menuextra.battery ShowPercent -string "YES"

###############################################################################
# Finder
###############################################################################

defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

###############################################################################
# Dock
###############################################################################

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5

###############################################################################
# Keyboard & Input
###############################################################################

defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad & Mouse
###############################################################################

defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5
defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.5
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

###############################################################################
# Screenshots
###############################################################################

mkdir -p "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Safari
###############################################################################

defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
defaults write com.apple.Safari ShowStatusBar -bool true
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

###############################################################################
# Restart affected applications
###############################################################################

for app in Dock Finder SystemUIServer; do
  killall "${app}" >/dev/null 2>&1 || true
done

echo "✅ macOS preferences configured. Some changes may require logout or restart."
