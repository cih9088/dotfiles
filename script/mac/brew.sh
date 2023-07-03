#!/usr/bin/env bash
# https://github.com/donnemartin/dev-setup/blob/master/brew.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Add default homebrew path
PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin${PATH+:$PATH}";

# MAC OS version
MACOS_VERSION=$(sw_vers -productVersion)
BIG_SUR_VERSION="11.0"
MONTEREY_VERISON="12.0"
################################################################

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  log_info "Install homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install mas
brew install mas
# Login to Appstore first
if verlte $MONTEREY_VERISON $MACOS_VERSION; then
  # monterey does not support account command
  # https://github.com/mas-cli/mas/issues/417
  log_info "Please signin Appstore manually and press any key."
  read anykey
else
  while true; do
    mas account
    [[ $? == 0 ]] && break
    log_info "Please signin Appstore manually and press any key."
    read anykey
  done
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
# sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum
# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
# Don’t forget to add `$(brew --prefix findutils)/libexec/gnubin` to `$PATH`.
brew install findutils
# Install GNU `sed`, `awk`, `grep`
# Don’t forget to add `$(brew --prefix gnu-sed)/libexec/gnubin` to `$PATH`.
brew install gnu-sed
brew install gawk
# Don’t forget to add `$(brew --prefix gnugrep)/libexec/gnubin` to `$PATH`.
brew install grep
# brew install gnu-indent --with-default-names
# brew install gnu-tar --with-default-names
# brew install gnu-which --with-default-names
# brew install gnutls

# Install Bash 5
brew install bash
# brew install bash-completion2
# # We installed the new shell, now we have to activate it
# echo "Adding the newly installed shell to the list of allowed shells"
# # Prompts for password
# sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
# # Change to the new shell, prompts for password
# chsh -s /usr/local/bin/bash

# Install `wget` with IRI support.
# brew install wget --with-iri
brew install wget

# Install python
brew install python
# # create symlink manually
# # https://github.com/Homebrew/homebrew-core/issues/16212
# ln -snf $(brew --prefix)/bin/python3 $(brew --prefix)/bin/python
# ln -snf $(brew --prefix)/bin/python3-config $(brew --prefix)/bin/python-config
# ln -snf $(brew --prefix)/bin/pip3 $(brew --prefix)/bin/pip
# ln -snf $(brew --prefix)/bin/wheel3 $(brew --prefix)/bin/wheel
# ln -snf $(brew --prefix)/bin/pydoc3 $(brew --prefix)/bin/pydoc

# Install ruby
brew install ruby

# Install more recent versions of some OS X tools.
# brew install vim --override-system-vi
brew install openssh

# Install other useful binaries.
# brew install ack
#brew install exiv2
brew install watch
brew install gzip
brew install pigz
brew install p7zip
brew install git
# brew install git-lfs
# brew install git-flow
# brew install git-extras
# brew install hub
# brew install imagemagick --with-webp
# brew install lua
# brew install lynx
brew install pv
# brew install rename
# brew install rhino
# brew install speedtest_cli
brew install ssh-copy-id
brew install esolitos/ipa/sshpass
brew install pssh
brew install mosh
brew install tree
# brew install webkit2png
# brew install zopfli
# brew install pkg-config libffi
brew install pandoc
brew install dockutil
brew install htop
brew install jq
brew install awscli
brew install azure-cli

# Lxml and Libxslt
# brew install libxml2
# brew install libxslt
# brew link libxml2 --force
# brew link libxslt --force

# Install quicklook plugins
# https://github.com/sindresorhus/quick-look-plugins
# https://github.com/haokaiyang/Mac-QuickLook
brew install --cask --appdir "/Applications/QuickLookPlugins" \
  qlstephen qlmarkdown syntax-highlight \
  quicklook-json qlimagesize suspicious-package apparency quicklookase qlvideo
xattr -d -r com.apple.quarantine ~/Library/QuickLook

# Install terminals
brew install --cask iterm2
brew install --cask alacritty
# download pretty icon for alacritty
[ -e /Applications/Alacritty.app ] && (
  curl -L 'https://www.dropbox.com/s/0i4ez0el7paksg3/Alacritty.icns' \
    -o /Applications/Alacritty.app/Contents/Resources/alacritty.icns
  touch /Applications/Alacritty.app
)
brew install --cask xquartz # -> requires password

# install SFMono patched with the nerd font
# https://github.com/epk/SF-Mono-Nerd-Font
brew tap epk/epk
brew install --cask font-sf-mono-nerd-font

# Install useful apps
brew install --cask google-chrome
brew install --cask skype
brew install --cask mos
# brew install --cask betterzip
brew install --cask keka
brew install --cask istat-menus
# brew install --cask stats
# brew install --cask eul
brew install --cask teamviewer # -> requires password
# brew install --cask vmware-fusion
brew install --cask parallels
# brew install --cask alt-tab
brew install --cask alfred
brew install --cask bartender
brew install --cask hazel
brew install --cask microsoft-office
brew install --cask openvpn-connect
brew tap homebrew/cask-drivers
brew install --cask synology-drive

# Install personally useful apps
brew install --cask dropbox
brew install --cask slack
brew install --cask inkscape
brew install --cask mactex # -> requires password
brew install --cask docker
brew install --cask mathpix-snipping-tool
brew install --cask notion
brew install --cask transmission
# brew install --cask swiftbar
brew tap homebrew/cask-versions
brew install --cask safari-technology-preview
brew install --cask paragon-ntfs
brew install --cask zotero
# brew install --cask virtualbox
# brew install --cask vagrant
# brew install --cask vagrant-manager


# install yabai
brew install koekeishiya/formulae/yabai
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(brew --prefix)/bin/yabai) --load-sa" | \
    sudo tee -a /private/etc/sudoers.d/yabai >/dev/null
# reinstall the scripting addition
sudo yabai --uninstall-sa || true
sudo yabai --install-sa || true
yabai --start-service
# load the scripting addition
killall Dock || true

# install skhd
brew install koekeishiya/formulae/skhd
skhd --start-service

# # install uebersicht
# brew install --cask ubersicht
# # install simplebar
# git clone https://github.com/Jean-Tinland/simple-bar $HOME/Library/Application\ Support/Übersicht/widgets/simple-bar

# install sketchybar
brew tap FelixKratz/formulae
brew install sketchybar
brew services start sketchybar

# install app font
app_font_version=$($DIR/../helpers/gh_get_latest_release "kvndrsslr/sketchybar-app-font")
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/${app_font_version}/sketchybar-app-font.ttf \
  -o $HOME/Library/Fonts/sketchybar-app-font.ttf
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/${app_font_version}/icon_map_fn.sh \
  -o $DIR/../../config/sketchybar/plugins/icon_map_fn.sh


## free stuff
# mas install 1018899653  # HeliumLift -> Download it manually
# mas install 937984704   # Amphetamine
mas install 409183694   # Keynote
mas install 409201541   # Pages
mas install 409203825   # Numbers
mas install 1295203466  # Microsoft Remote Desktop
mas install 1114196460  # Rocket Fuel
# mas install 414855915   # WinArchiver Lite
mas install 1462114288  # Grammarly for Safari
mas install 1445910651  # Dynamo
mas install 869223134   # KakaoTalk
mas install 1480933944  # Vimari
mas install 1559269364  # Notion Web Clipper
mas install 1519867270  # Refined GitHub


## not free
mas install 445189367   # PopClip
mas install 441258766   # Magnet
mas install 461788075   # Movist
mas install 577085396   # Unclutter
mas install 1231935892  # Unicorn Blocker:Adblock
mas install 1475628500  # Unicorn HTTPS
mas install 922765270   # LiquidText


# Remove outdated versions from the cellar.
brew cleanup
