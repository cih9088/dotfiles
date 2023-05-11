#!/usr/bin/env bash
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Add default homebrew path
PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin${PATH+:$PATH}";
################################################################


###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# # Set highlight color to a specific yellow
# defaults write NSGlobalDomain AppleHighlightColor -string '0.984300 0.929400 0.450900'

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Always show scrollbars
# Possible values: `WhenScrolling`, `Automatic` and `Always`
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# # Disable the over-the-top focus ring animation
# defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Adjust toolbar title rollover delay
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false


###############################################################################
# Date and Time
###############################################################################

# Thu 18 Aug 23:46
# System Preferences > Date & Time > Display time with seconds - Checked [:ss]
# System Preferences > Date & Time > Use a 24-hour clock - Checked [HH:mm]
# System Preferences > Date & Time > Show AM/PM - Unchecked
# System Preferences > Date & Time > Show the day of the week - Checked [EEE]
# System Preferences > Date & Time > Show date - Checked [d MMM]
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm"


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

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

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# normal minimum is 15 (225 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# normal minimum is 2 (30 ms)
defaults write NSGlobalDomain KeyRepeat -int 2

# Enable function key as is
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Mapping modifier key for embedded keyboard
vendor_id=$(printf "%d" $(hidutil list | grep -i 'Apple' | grep -i 'Internal' | grep -i 'Keyboard' | awk '{print $1}' | head -n 1))
product_id=$(printf "%d" $(hidutil list | grep -i 'Apple' | grep -i 'Internal' | grep -i 'Keyboard' | awk '{print $2}' | head -n 1))
# vendor_id=$(printf "%d" $(system_profiler SPUSBDataType | grep 'Internal' -A 5 | awk '/Vendor ID/{print $3}'))
# product_id=$(printf "%d" $(system_profiler SPUSBDataType | grep 'Internal' -A 5 | awk '/Product ID/{print $3}'))
# None — –1
# Caps Lock — 0
# Shift (Left) — 1
# Control (Left) — 2
# Option (Left) — 3
# Command (Left) — 4
# Keypad 0 — 5
# Help — 6
# Shift (Right) — 9
# Control (Right) — 10
# Option (Right) — 11
# Command (Right) — 12
if [[ ${vendor_id} != "" && ${product_id} != "" ]]; then
  defaults -currentHost remove -g com.apple.keyboard.modifiermapping.${vendor_id}-${product_id}-0
  defaults -currentHost write -g com.apple.keyboard.modifiermapping.${vendor_id}-${product_id}-0 \
    -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>2</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'
  defaults -currentHost write -g com.apple.keyboard.modifiermapping.${vendor_id}-${product_id}-0 \
    -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>0</integer><key>HIDKeyboardModifierMappingSrc</key><integer>2</integer></dict>'
fi



###############################################################################
# Energy saving                                                               #
###############################################################################

# Enable lid wakeup
sudo pmset -a lidwake 1

# Sleep the display after 5 minutes
sudo pmset -a displaysleep 5

# Set machine sleep to 10 minutes while charging
sudo pmset -c sleep 10

# Set machine sleep to 5 minutes on battery
sudo pmset -b sleep 5

## Remove the sleep image file to save disk space
#sudo rm /private/var/vm/sleepimage
## Create a zero-byte file instead…
#sudo touch /private/var/vm/sleepimage
## …and make sure it can’t be rewritten
#sudo chflags uchg /private/var/vm/sleepimage


###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Activate screensaver after 2 minutes
defaults -currentHost write com.apple.screensaver idleTime -int 120

# Show clock on screensaver
defaults -currentHost write com.apple.screensaver showClock -bool true

# Set screensaver as drift
defaults -currentHost write com.apple.screensaver moduleDict \
  -dict moduleName Drift path /System/Library/Screen\ Savers/Drift.saver type 0

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true


###############################################################################
# Dock                                                                        #
###############################################################################

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set orientation of dock
defaults write com.apple.dock "orientation" -string "bottom"

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "genie"

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 35

# Add magnification to dock
defaults write com.apple.dock magnification -bool true

# Set magnificated dock items
defaults write com.apple.dock largesize -int 60

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

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# Top left screen corner → Mission Control
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
# Bottom right screen corner → Desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0
# Bottom left screen corner → Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0


# # Menu bar
# # Hide siri
# defaults write com.apple.Siri StatusMenuVisible -bool false
# # Hide spotlight
# defaults delete com.apple.Spotlight "NSStatusItem Visible Item-0"



###############################################################################
# Display                                                                     #
###############################################################################

# Displays have separate Spaces
defaults write com.apple.spaces spans-displays -bool false


###############################################################################
# Finder                                                                      #
###############################################################################

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
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

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
find $HOME -name ".DS_Store" -delete

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

# # The warning before emptying the Trash
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

# # Show the /Volumes folder
# sudo chflags nohidden /Volumes

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true


###############################################################################
# Safari                                                                      #
###############################################################################

# # Privacy: don’t send search queries to Apple
# defaults write -app Safari UniversalSearchEnabled -bool false
# defaults write -app Safari SuppressSearchSuggestions -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write -app Safari AutoOpenSafeDownloads -bool false

# # Enable Safari’s debug menu
# defaults write -app Safari IncludeInternalDebugMenu -bool true

# Enable the Develop menu and the Web Inspector in Safari
defaults write -app Safari IncludeDevelopMenu -bool true
# defaults write -app Safari.SandboxBroker ShowDevelopMenu -bool true
# defaults write -app Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
# defaults write -app Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# # Add a context menu item for showing the Web Inspector in web views
# defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# # Block pop-up windows
# defaults write -app Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
# defaults write -app Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# # Enable “Do Not Track”
# defaults write -app Safari SendDoNotTrackHTTPHeader -bool true

# # Update extensions automatically
# defaults write -app Safari InstallExtensionUpdatesAutomatically -bool true



###############################################################################
# RocketFuel.app                                                              #
###############################################################################
if [[ -e "/Applications/RocketFuel.app" ]]; then
  defaults write com.ardalansamimi.RocketFuel launchAtLogin -int 1
  defaults write com.ardalansamimi.RocketFuel leftClickActivation -int 1
fi


###############################################################################
# Unclutter.app                                                               #
###############################################################################
if [[ -e "/Applications/Unclutter.app" ]]; then
  defaults write com.softwareambience.Unclutter LaunchAtStartup -bool true
fi


###############################################################################
# Alfred.app                                                                  #
###############################################################################
if [[ -e "/Applications/Alfred 4.app" ]]; then
  defaults write com.runningwithcrayons.Alfred-Preferences syncfolder -string "~/Library/Mobile Documents/com~apple~CloudDocs"
fi


###############################################################################
# Stats.app                                                                   #
###############################################################################
if [[ -e "/Applications/Stats.app" ]]; then
  defaults write eu.exelban.Stats runAtLoginInitialized -int    1
  defaults write eu.exelban.Stats CPU_bar_chart_color   -string "Pink"
  defaults write eu.exelban.Stats CPU_state             -int    1
  defaults write eu.exelban.Stats CPU_updateInterval    -int    30
  defaults write eu.exelban.Stats CPU_processes         -int    8
  defaults write eu.exelban.Stats CPU_widget            -string "bar_chart"
  defaults write eu.exelban.Stats CPU_line_chart_box    -int    1
  defaults write eu.exelban.Stats CPU_line_chart_frame  -int    0
  defaults write eu.exelban.Stats CPU_line_chart_value  -int    0
  defaults write eu.exelban.Stats GPU_state             -int    0
  defaults write eu.exelban.Stats GPU_updateInterval    -int    30
  defaults write eu.exelban.Stats GPU_widget            -string "bar_chart"
  defaults write eu.exelban.Stats GPU_line_chart_box    -int    1
  defaults write eu.exelban.Stats GPU_line_chart_frame  -int    0
  defaults write eu.exelban.Stats GPU_line_chart_value  -int    0
  defaults write eu.exelban.Stats Disk_state            -int    1
  defaults write eu.exelban.Stats Disk_widget           -string "bar_chart"
  defaults write eu.exelban.Stats Disk_updateInterval   -int    30
  defaults write eu.exelban.Stats SSD_bar_chart_box     -int    1
  defaults write eu.exelban.Stats SSD_bar_chart_color   -string "Pink"
  defaults write eu.exelban.Stats RAM_state             -int    1
  defaults write eu.exelban.Stats RAM_widget            -string "bar_chart"
  defaults write eu.exelban.Stats RAM_bar_chart_color   -string "Pink"
  defaults write eu.exelban.Stats RAM_updateInterval    -int    30
  defaults write eu.exelban.Stats Network_speed_base    -string "byte"
  defaults write eu.exelban.Stats Network_speed_icon    -string "dots"
  defaults write eu.exelban.Stats Battery_state         -int    0
fi


###############################################################################
# Hazel.app                                                                   #
###############################################################################
if [[ -e "/Applications/Hazel.app" ]]; then
  defaults write com.noodlesoft.hazel TrashUninstallApps -bool true
fi


###############################################################################
# Transmission.app                                                            #
###############################################################################
if [[ -e "/Applications/Transmission.app" ]]; then
  # Don’t prompt for confirmation before downloading
  defaults write org.m0k.transmission DownloadAsk -bool false

  # Use `~/Downloads/.transmission` to store incomplete downloads
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
fi


# ###############################################################################
# # Keka.app                                                                    #
# ###############################################################################
# if [[ -e "/Applications/Keka.app" ]]; then
#   defaults write com.aone.keka SetAsDefaultApp -bool true
# fi



###############################################################################
# iTerm2.app                                                                  #
###############################################################################
if [[ -e "/Applications/iTerm.app" ]]; then
  # Specify the preferences directory
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/config/iterm2"
  # Tell iTerm2 to use the custom preferences in the directory
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

  # copy script
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  cp -r $DIR/../../config/iterm2/AutoLaunch ~/Library/Application\ Support/iterm2/Scripts
fi


###############################################################################
# Dockutil                                                                    #
###############################################################################
if command -v dockutil > /dev/null; then
  dockutil --add "/Applications" --view list --display folder --sort name --before "Downloads"
  [ -e "/Applications/Google Chrome.app" ] &&
    dockutil --add /Applications/Google\ Chrome.app --after "Safari"
  [ -e "/Applications/Safari Technology Preview.app" ] &&
    dockutil --add /Applications/Safari\ Technology\ Preview.app --after "Safari"
  [ -e "/Applications/Notion.app" ] &&
    dockutil --add /Applications/Notion.app
  [ -e "/Applications/Alacritty.app" ] &&
    dockutil --add /Applications/Alacritty.app
  [ -e "/Applications/Slack.app" ] &&
    dockutil --add /Applications/Slack.app
fi



for app in \
  "cfprefsd" \
  "Dock" \
  "Finder" \
  "Safari" \
  "SystemUIServer" \
  "Transmission"
do
  killall "${app}" || true
done
