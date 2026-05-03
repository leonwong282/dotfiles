#!/usr/bin/env bash

# macOS Preferences Setup Script

# Close System Preferences to prevent conflicts
osascript -e 'tell application "System Preferences" to quit'

echo "Setting up macOS preferences..."

###############################################################################
# General UI/UX
###############################################################################

echo "Configuring UI/UX..."

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Menu bar: show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

###############################################################################
# Finder
###############################################################################

echo "Configuring Finder..."

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show full path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Default view style (icons, list, columns, gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Nlsv = list, icnv = icons, clmv = columns, glyv = gallery

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"


###############################################################################
# Dock
###############################################################################

echo "Configuring Dock..."

# Auto-hide Dock
defaults write com.apple.dock autohide -bool true

# Dock position (left, bottom, right)
defaults write com.apple.dock orientation -string "left"

# Dock size
defaults write com.apple.dock tilesize -int 48

# Magnification
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64

# Minimize effect (genie, scale)
defaults write com.apple.dock mineffect -string "scale"

# Show recent applications
defaults write com.apple.dock show-recents -bool false

# Faster show/hide animation
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5

###############################################################################
# Keyboard & Input
###############################################################################

echo "Configuring keyboard..."

# Faster key repeat (1 = fastest)
defaults write NSGlobalDomain KeyRepeat -int 1

# Shorter initial delay (10 = shortest)
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad & Mouse
###############################################################################

# Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Tracking speed (0-3, higher = faster)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5
defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.5


defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "true"

###############################################################################
# Screenshots
###############################################################################

echo "Configuring screenshots..."

# Save to dedicated folder
mkdir -p "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"

# Save as PNG
defaults write com.apple.screencapture type -string "png"

# Disable shadow
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Safari
###############################################################################
# Show full URL in address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Show status bar
defaults write com.apple.Safari ShowStatusBar -bool true

# Enable debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Enable develop menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

# Disable auto-open safe files
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

###############################################################################
# Restart affected applications
###############################################################################

echo "Restarting affected applications..."

for app in "Dock" "Finder" "SystemUIServer"; do
  killall "${app}" &> /dev/null
done

echo "✅ macOS preferences configured!"
echo "Note: Some changes require logout/restart to take full effect."