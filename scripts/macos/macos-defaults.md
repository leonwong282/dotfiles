# macOS Defaults Configuration

This file contains the configuration for macOS system defaults managed by this dotfiles repository.
The scripts `defaults.sh` and `export-defaults.sh` parse this Markdown table to apply or verify settings.

**Note on variables:** `${SCREENSHOT_DIR}` is supported and will be expanded automatically by the scripts.

| Category    | Description                                     | Domain                  | Key                                  | Type   | Value             | Restart        | Risk |
|-------------|-------------------------------------------------|-------------------------|--------------------------------------|--------|-------------------|----------------|------|
| global      | Show all filename extensions                    | NSGlobalDomain          | AppleShowAllExtensions               | bool   | true              | Finder         | low  |
| global      | Expand save panel by default                    | NSGlobalDomain          | NSNavPanelExpandedStateForSaveMode   | bool   | true              |                | low  |
| global      | Expand save panel by default, modern key        | NSGlobalDomain          | NSNavPanelExpandedStateForSaveMode2  | bool   | true              |                | low  |
| global      | Expand print panel by default                   | NSGlobalDomain          | PMPrintingExpandedStateForPrint      | bool   | true              |                | low  |
| global      | Expand print panel by default, modern key       | NSGlobalDomain          | PMPrintingExpandedStateForPrint2     | bool   | true              |                | low  |
| global      | Disable automatic capitalization                | NSGlobalDomain          | NSAutomaticCapitalizationEnabled     | bool   | false             |                | low  |
| global      | Disable smart quotes                            | NSGlobalDomain          | NSAutomaticQuoteSubstitutionEnabled  | bool   | false             |                | low  |
| global      | Disable smart dashes                            | NSGlobalDomain          | NSAutomaticDashSubstitutionEnabled   | bool   | false             |                | low  |
| global      | Disable automatic period substitution           | NSGlobalDomain          | NSAutomaticPeriodSubstitutionEnabled | bool   | false             |                | low  |
| global      | Disable automatic spelling correction           | NSGlobalDomain          | NSAutomaticSpellingCorrectionEnabled | bool   | false             |                | low  |
| global      | Disable press-and-hold for keys in favor of key repeat | NSGlobalDomain | ApplePressAndHoldEnabled             | bool   | false             |                | low  |
| global      | Set full keyboard access for all controls       | NSGlobalDomain          | AppleKeyboardUIMode                  | int    | 3                 |                | low  |
| global      | Always show scrollbars                          | NSGlobalDomain          | AppleShowScrollBars                  | string | Always            |                | low  |
| global      | Save to disk (not to iCloud) by default         | NSGlobalDomain          | NSDocumentSaveNewDocumentsToCloud    | bool   | false             |                | low  |
| finder      | Show Finder path bar                            | com.apple.finder        | ShowPathbar                          | bool   | true              | Finder         | low  |
| finder      | Show Finder status bar                          | com.apple.finder        | ShowStatusBar                        | bool   | true              | Finder         | low  |
| finder      | Show all filename extensions                    | NSGlobalDomain          | AppleShowAllExtensions               | bool   | true              | Finder         | low  |
| finder      | Search current folder by default                | com.apple.finder        | FXDefaultSearchScope                 | string | SCcf              | Finder         | low  |
| finder      | Keep folders on top when sorting by name        | com.apple.finder        | _FXSortFoldersFirst                  | bool   | true              | Finder         | low  |
| finder      | Show POSIX path in Finder title                 | com.apple.finder        | _FXShowPosixPathInTitle              | bool   | true              | Finder         | low  |
| finder      | Set Finder new window target to Downloads       | com.apple.finder        | NewWindowTarget                      | string | PfLo              | Finder         | low  |
| finder      | Set Finder new window target path to Downloads  | com.apple.finder        | NewWindowTargetPath                  | string | file://${HOME}/Downloads/ | Finder  | low  |
| finder      | Set default Finder group by to None             | com.apple.finder        | FXPreferredGroupBy                   | string | None                      | Finder  | low  |
| finder      | Set default Finder sort order to Name           | com.apple.finder        | FXPreferredSortOrder                 | string | Name                      | Finder  | low  |
| finder      | Set Icon View sort order to name                | com.apple.finder        | :StandardViewSettings:IconViewSettings:arrangeBy | plist-string | name | Finder | low  |
| finder      | Disable warning when changing a file extension  | com.apple.finder        | FXEnableExtensionChangeWarning       | bool   | false             | Finder         | low  |
| dock        | Set Dock tile size to 48 pixels                 | com.apple.dock          | tilesize                             | int    | 48                        | Dock           | low  |
| dock        | Use scale minimize effect                       | com.apple.dock          | mineffect                            | string | scale             | Dock           | low  |
| dock        | Show indicators for open applications           | com.apple.dock          | show-process-indicators              | bool   | true              | Dock           | low  |
| dock        | Hide recent applications in Dock                | com.apple.dock          | show-recents                         | bool   | false             | Dock           | low  |
| dock        | Set top-left hot corner to Screen Saver         | com.apple.dock          | wvous-tl-corner                      | int    | 5                 | Dock           | low  |
| dock        | Minimize windows into application icon          | com.apple.dock          | minimize-to-application              | bool   | true              | Dock           | low  |
| dock        | Automatically hide and show the Dock            | com.apple.dock          | autohide                             | bool   | true              | Dock           | low  |
| dock        | Make icons of hidden applications translucent   | com.apple.dock          | showhidden                           | bool   | true              | Dock           | low  |
| dock        | Don't automatically rearrange Spaces based on most recent use | com.apple.dock | mru-spaces                  | bool   | false             | Dock           | low  |
| dock        | Don't group windows by application in Mission Control | com.apple.dock    | expose-group-apps                    | bool   | false             | Dock           | low  |
| screenshots | Save screenshots as PNG                         | com.apple.screencapture | type                                 | string | png               | SystemUIServer | low  |
| screenshots | Save screenshots to Pictures/Screenshots        | com.apple.screencapture | location                             | string | ${SCREENSHOT_DIR} | SystemUIServer | low  |
| screenshots | Disable shadow in screenshots                   | com.apple.screencapture | disable-shadow                       | bool   | true              | SystemUIServer | low  |
| keyboard    | Set reasonable key repeat rate                  | NSGlobalDomain          | KeyRepeat                            | int    | 2                 |                | low  |
| keyboard    | Set reasonable initial key repeat delay         | NSGlobalDomain          | InitialKeyRepeat                     | int    | 15                |                | low  |
| safari      | Show the full URL in the address bar            | com.apple.Safari        | ShowFullURLInSmartSearchField        | bool   | true              | Safari         | low  |
| safari      | Prevent Safari from opening 'safe' files automatically | com.apple.Safari | AutoOpenSafeDownloads                | bool   | false             | Safari         | low  |
| safari      | Set Safari home page to about:blank             | com.apple.Safari        | HomePage                             | string | about:blank       | Safari         | low  |
| safari      | Enable the Develop menu and the Web Inspector   | com.apple.Safari        | IncludeDevelopMenu                   | bool   | true              | Safari         | low  |
| safari      | Enable WebKit Developer Extras                  | com.apple.Safari        | WebKitDeveloperExtrasEnabledPreferenceKey | bool | true              | Safari         | low  |
| safari      | Enable WebKit Developer Extras (Content Page)   | com.apple.Safari        | com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled | bool | true | Safari | low  |
| safari      | Enable WebKit Developer Extras (Global)         | NSGlobalDomain          | WebKitDeveloperExtras                | bool   | true              | Safari         | low  |
| safari      | Warn about fraudulent websites                  | com.apple.Safari        | WarnAboutFraudulentWebsites          | bool   | true              | Safari         | low  |
| misc        | Avoid creating .DS_Store files on network volumes | com.apple.desktopservices | DSDontWriteNetworkStores         | bool   | true              |                | low  |
| misc        | Avoid creating .DS_Store files on USB volumes   | com.apple.desktopservices | DSDontWriteUSBStores             | bool   | true              |                | low  |
