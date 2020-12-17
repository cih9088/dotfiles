#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


## General
# Always show scrollbars
# Possible values: `WhenScrolling`, `Automatic` and `Always`
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


## Trackpad
# Enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackPad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Use three finger to drag
#defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -bool false
#defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -bool false
#defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad HIDScrollZoomModifierMask -int 262144
defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true



## Keyboard
# capslock to control
# control to capslock
# normal minimum is 15 (225 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 12 
# normal minimum is 2 (30 ms)
defaults write NSGlobalDomain KeyRepeat -int 2
# Enable function key as is
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false


## etc
# # Disable machine sleep while charging
# sudo pmset -c sleep 0
## Remove the sleep image file to save disk space
#sudo rm /private/var/vm/sleepimage
## Create a zero-byte file instead…
#sudo touch /private/var/vm/sleepimage
## …and make sure it can’t be rewritten
#sudo chflags uchg /private/var/vm/sleepimage


## Screen
# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true


## Dock

# Set the icon size of Dock items to 24 pixels
defaults write com.apple.dock tilesize -int 30
# Add magnification to dock
defaults write com.apple.dock magnification -bool true
# Set magnificated dock items to 48 pixels
defaults write com.apple.dock largesize -int 60
# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "genie"
# Do not minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool false
# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true
# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1
# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-apps -bool false
# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# # Remove the animation when hiding/showing the Dock
# defaults write com.apple.dock autohide-time-modifier -float 0
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
# # Dock to left
# defaults write com.apple.dock orientation left
# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true
# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false
# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true


## Menu bar
# Hide siri
defaults write com.apple.Siri StatusMenuVisible -bool false
# Hide spotlight
#defaults delete com.apple.Spotlight "NSStatusItem Visible Item-0"



## Safari
# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true
#defaults write com.apple.Safari IncludeDevelopMenu -bool true
#defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
#defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true


## Display
# scaled to more space
# Displays have separate Spaces
defaults write com.apple.spaces spans-displays -bool false

## Finder
# new finder windows show to home
# sidebar all
#
# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
# Computer     : `PfCm`
# Volume       : `PfVo`
# $HOME        : `PfHm`
# Desktop      : `PfDe`
# Documents    : `PfDo`
# All My Files : `PfAF`
# Other…       : `PfLo`
defaults write com.apple.finder NewWindowTarget -string "PfHm"
# defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
# Window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool false
# Icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop         -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop     -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop     -bool true
# Filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions     -bool true
# File extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Path bar
defaults write com.apple.finder ShowPathbar -bool true
# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Search scope
# This Mac       : `SCev`
# Current Folder : `SCcf`
# Previous Scope : `SCsp`
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true
# # Arrange by
# # Kind, Name, Application, Date Last Opened,
# # Date Added, Date Modified, Date Created, Size, Tags, None
# defaults write com.apple.finder FXArrangeGroupViewBy -string "Kind"
# Preferred view style
# Icon View   : `icnv`
# List View   : `Nlsv`
# Column View : `clmv`
# Cover Flow  : `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# After configuring preferred view style, clear all `.DS_Store` files
# to ensure settings are applied for every directory
# sudo find / -name ".DS_Store" --delete
# Disable file extension change warning.
defaults write com.apple.finder FXEnableExtensionsChangeWarning -bool false
# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
# Tweak the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float .5
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist
# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist
# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true



## Rocket
defaults write com.ardalansamimi.RocketFuel launchAtLogin -int 1
defaults write com.ardalansamimi.RocketFuel leftClickActivation -int 1


## Alfred
defaults write com.runningwithcrayons.Alfred-Preferences syncfolder -string "~/Library/Mobile Documents/com~apple~CloudDocs"


# # Mos
# defaults write com.caldis.Mos


# # stats
# defaults write eu.exelban.Stats runAtLoginInitialized -int    1
# defaults write eu.exelban.Stats CPU_state             -int    1
# defaults write eu.exelban.Stats CPU_updateInterval    -int    30
# defaults write eu.exelban.Stats CPU_processes         -int    8
# defaults write eu.exelban.Stats CPU_widget            -string "line_chart"
# defaults write eu.exelban.Stats CPU_line_chart_box    -int    1
# defaults write eu.exelban.Stats CPU_line_chart_frame  -int    0
# defaults write eu.exelban.Stats CPU_line_chart_value  -int    0
# defaults write eu.exelban.Stats GPU_state             -int    0
# defaults write eu.exelban.Stats GPU_updateInterval    -int    30
# defaults write eu.exelban.Stats GPU_widget            -string "line_chart"
# defaults write eu.exelban.Stats GPU_line_chart_box    -int    1
# defaults write eu.exelban.Stats GPU_line_chart_frame  -int    0
# defaults write eu.exelban.Stats GPU_line_chart_value  -int    0
# defaults write eu.exelban.Stats Disk_state            -int    1
# defaults write eu.exelban.Stats Disk_widget           -string "bar_chart"
# defaults write eu.exelban.Stats Disk_updateInterval   -int    30
# defaults write eu.exelban.Stats RAM_state             -int    1
# defaults write eu.exelban.Stats RAM_widget            -string "bar_chart"
# defaults write eu.exelban.Stats RAM_updateInterval    -int    30
# defaults write eu.exelban.Stats Network_speed_base    -string "byte"
# defaults write eu.exelban.Stats Network_speed_icon    -string "dots"
# defaults write eu.exelban.Stats Battery_state         -int    0

# eul

# hazel
defaults write com.noodlesoft.hazel TrashUninstallApps -bool true


## transmission
# Don’t prompt for confirmation before downloading
defaults write org.m0k.transmission DownloadAsk -bool false
# Use `~/Downloads/Torrents` to store incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/.transmission"
# Disable to show downloadrate
defaults write org.m0k.transmission BadgeDownloadRate -int 0
# Disable to show uploadrate
defaults write org.m0k.transmission BadgeUploadRate -int 0
# Trash original torrent files
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true
# UploadLimit
defaults write org.m0k.transmission UploadLimit -int 1
defaults write org.m0k.transmission CheckUpload -bool true
# Do not rename partial files
defaults write org.m0k.transmission RenamePartialFiles -int 0


## alt-tab
defaults write com.lwouis.alt-tab-macos windowMaxWidthInRow   -int    80
defaults write com.lwouis.alt-tab-macos windowMinWidthInRow   -int    50
defaults write com.lwouis.alt-tab-macos maxHeightOnScreen     -int    40
defaults write com.lwouis.alt-tab-macos maxWidthOnScreen      -int    70
defaults write com.lwouis.alt-tab-macos iconSize              -int    25
defaults write com.lwouis.alt-tab-macos fontHeight            -int    15
defaults write com.lwouis.alt-tab-macos hideSpaceNumberLabels -bool   true
defaults write com.lwouis.alt-tab-macos hideThumbnails        -bool   true
defaults write com.lwouis.alt-tab-macos hideWindowlessApps    -bool   true
defaults write com.lwouis.alt-tab-macos holdShortcut          -string "\\U2318";
defaults write com.lwouis.alt-tab-macos holdShortcut2         -string "\\U2318";


## keka
defaults write com.aone.keka SetAsDefaultApp -bool true



cat <<EOF
# TODO
1. Change modifier key
2. Enable safari extensions
3. Adjust resolution
4. Reboot
EOF

for app in "cfprefsd" \
	"Dock" \
	"Finder" \
	"Safari" \
	"SystemUIServer" \
	"Transmission"; do
	killall "${app}" &> /dev/null
done
