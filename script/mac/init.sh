#!/usr/bin/env bash
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# https://macos-defaults.com/
# https://github.com/tpvasconcelos/dotfiles/blob/main/scripts/macos.zsh

# How to check for changes in "defaults"
# $ defaults read | sed -e 's/[0-9]\{4\}-[01][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]/DATE_REMOVED/g' | sed -E 's/Age = "[0-9]+\.[0-9]+"/AGE_REDACTED/g' > dft1.plist
# make your changes...
# $ defaults read | sed -e 's/[0-9]\{4\}-[01][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]/DATE_REMOVED/g' | sed -E 's/Age = "[0-9]+\.[0-9]+"/AGE_REDACTED/g' > dft2.plist
# $ diffmerge dft1.plist dft2.plist

# How to check the id of an Application
# $ osascript -e 'id of app "Safari"'
# com.apple.Safari
# $ osascript -e 'id of app "Pycharm"'
# com.jetbrains.pycharm
# etc...

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
sudo nvram StartupMute=%01

# Set sidebar icon size to medium
# Possible values: 1(small), 2(medium, default), 3(large)
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Show scollbar
# Possible values: `WhenScrolling`, `Automatic` (default) and `Always`
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"

# # Disable the over-the-top focus ring animation
# defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Adjust toolbar title rollover (e.g. show full path in finder) delay
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# # Save to disk (not to iCloud) by default
# defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

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

defaults write com.apple.menuextra.clock ShowDate -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

## Trackpad

# Enable tap to click for trackpads
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackPad Clicking -bool true
# Enable tap to click for the current user
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable horizontal three-finger swiping for three-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
# Disable vertical three-finger swiping for three-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
# Diable three-finger look up
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
# Enable three-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Enable horizontal four-finger swiping for four-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 0
# Enable vertical four-finger swiping for four-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 0

# Enable three/four-finger swipe down for App Expose
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad HIDScrollZoomModifierMask -int 262144
defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 262144
# Set zoom style to Picture-in-Picture
defaults write com.apple.universalaccess closeViewZoomMode -int 1
# Follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true
# Keep pointer centered while zoomed
defaults write com.apple.universalaccess closeViewPanningMode -int 2


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

# Enable lid wakeup (will be ignored on apple silicon)
sudo pmset -a lidwake 1

# Sleep the display after 5 minutes
sudo pmset -a displaysleep 5

# Set machine sleep to 10 minutes while charging
sudo pmset -c sleep 10
sudo pmset -c disksleep 10

# Set machine sleep to 5 minutes on battery
sudo pmset -b sleep 5
sudo pmset -b disksleep 5

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

# # Save screenshots to the desktop
# defaults write com.apple.screencapture location -string "${HOME}/Desktop"

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
defaults write com.apple.dock orientation -string "bottom"

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

# Group windows by application in Mission Control
defaults write com.apple.dock expose-group-apps -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# # Remove the animation when hiding/showing the Dock
# defaults write com.apple.dock autohide-time-modifier -float 0

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Show recent applications in Dock
defaults write com.apple.dock show-recents -bool true

# # Hot corners
# # Possible values:
# #  0: no-op
# #  2: Mission Control
# #  3: Show application windows
# #  4: Desktop
# #  5: Start screen saver
# #  6: Disable screen saver
# #  7: Dashboard
# # 10: Put display to sleep
# # 11: Launchpad
# # 12: Notification Center
# # 13: Lock Screen
# # Top left screen corner → Mission Control
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0
# # Bottom right screen corner → Desktop
# defaults write com.apple.dock wvous-br-corner -int 4
# defaults write com.apple.dock wvous-br-modifier -int 0
# # Bottom left screen corner → Start screen saver
# defaults write com.apple.dock wvous-bl-corner -int 5
# defaults write com.apple.dock wvous-bl-modifier -int 0


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
defaults write com.apple.finder ShowHardDrivesOnDesktop         -bool true
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
# # After configuring preferred view style, clear all `.DS_Store` files
# # to ensure settings are applied for every directory
# find $HOME -name ".DS_Store" -delete

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
chflags nohidden ~/Library

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

for app_name in "Safari" "Safari Technology Preview"; do
  if [[ ! -e "/Applications/$app_name.app" ]]; then
    continue
  fi

  # # Privacy: don’t send search queries to Apple
  # defaults write -app Safari UniversalSearchEnabled -bool false
  # defaults write -app Safari SuppressSearchSuggestions -bool true

  # Prevent Safari from opening ‘safe’ files automatically after downloading
  defaults write -app "$app_name" AutoOpenSafeDownloads -bool false

  # Enable the Develop menu and the Web Inspector in "$app_name"
  defaults write -app "$app_name" IncludeDevelopMenu -bool true

  # Enable the bottom hover status bar
  defaults write -app "$app_name" ShowOverlayStatusBar -bool true

  # # Add a context menu item for showing the Web Inspector in web views
  # defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # # Block pop-up windows
  # defaults write -app "$app_name" WebKitJavaScriptCanOpenWindowsAutomatically -bool false
  # defaults write -app "$app_name" com.apple."$app_name".ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

  # # Enable “Do Not Track”
  # defaults write -app "$app_name" SendDoNotTrackHTTPHeader -bool true

  # # Update extensions automatically
  # defaults write -app "$app_name" InstallExtensionUpdatesAutomatically -bool true
done



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
