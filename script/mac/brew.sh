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
MONTEREY_VERISON="12.0"
################################################################

# Check for Homebrew,
# Install if we don't have it
if test ! "$(which brew)"; then
  log_info "Install homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install mas
brew install --yes mas
# Login to Appstore first
if verlte "$MONTEREY_VERISON" "$MACOS_VERSION"; then
  # monterey and above does not support account command
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
brew install --yes coreutils
# sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum
# Install some other useful utilities like `sponge`.
brew install --yes moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
# Don’t forget to add `$(brew --prefix findutils)/libexec/gnubin` to `$PATH`.
brew install --yes findutils
# Install GNU `sed`, `awk`, `grep`
# Don’t forget to add `$(brew --prefix gnu-sed)/libexec/gnubin` to `$PATH`.
brew install --yes gnu-sed
brew install --yes gawk
# Don’t forget to add `$(brew --prefix gnugrep)/libexec/gnubin` to `$PATH`.
brew install --yes grep
# brew install --yes gnu-indent
# brew install --yes gnu-tar
# brew install --yes gnu-which
# brew install --yes gnutls

# Install Bash 5
brew install --yes bash
brew install --yes bash-completion@2
# # We installed the new shell, now we have to activate it
# echo "Adding the newly installed shell to the list of allowed shells"
# # Prompts for password
# sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
# # Change to the new shell, prompts for password
# chsh -s /usr/local/bin/bash

# Install python
brew install --yes python
# # create symlink manually
# # https://github.com/Homebrew/homebrew-core/issues/16212
# ln -snf $(brew --prefix)/bin/python3 $(brew --prefix)/bin/python
# ln -snf $(brew --prefix)/bin/python3-config $(brew --prefix)/bin/python-config
# ln -snf $(brew --prefix)/bin/pip3 $(brew --prefix)/bin/pip
# ln -snf $(brew --prefix)/bin/wheel3 $(brew --prefix)/bin/wheel
# ln -snf $(brew --prefix)/bin/pydoc3 $(brew --prefix)/bin/pydoc

# Install ruby
brew install --yes ruby

# Install more recent versions of some OS X tools.
# brew install --yes vim
brew install --yes openssh

# Install other useful binaries.
brew install --yes wget
# brew install --yes exiv2
brew install --yes fzf
brew install --yes watch
brew install --yes gzip pigz
brew install --yes p7zip
brew install --yes git
brew install --yes git-lfs
# brew install --yes git-extras
brew install --yes gh
# brew install --yes imagemagick --with-webp
# brew install --yes lynx
brew install --yes pv
# brew install --yes rename
# brew install --yes speedtest-cli
brew install --yes ssh-copy-id
brew install --yes esolitos/ipa/sshpass
brew install --yes pssh
brew install --yes mosh
brew install --yes tree
# brew install --yes webkit2png
# brew install --yes zopfli
# brew install --yes pkg-config libffi
brew install --yes pandoc
brew install --yes dockutil
brew install --yes htop
brew install --yes jq
brew install --yes awscli
brew install --yes azure-cli
brew install --yes gcloud-cli
brew install --yes kubernetes-cli
brew install --yes helm

# Lxml and Libxslt
# brew install --yes libxml2
# brew install --yes libxslt
# brew link libxml2 --force
# brew link libxslt --force

# # Install quicklook plugins
# # https://github.com/sindresorhus/quick-look-plugins
# # https://github.com/haokaiyang/Mac-QuickLook
# brew install --yes --cask \
#   qlmarkdown qlvideo
#   qlstephen syntax-highlight \
#   quicklook-json suspicious-package apparency quicklookase qlvideo
# xattr -d -r com.apple.quarantine ~/Library/QuickLook

# Install terminals
# brew install --yes --cask iterm2
#brew install --yes --cask alacritty
## download pretty icon for alacritty
#[ -e /Applications/Alacritty.app ] && (
#  curl -L 'https://www.dropbox.com/s/0i4ez0el7paksg3/Alacritty.icns' \
#    -o /Applications/Alacritty.app/Contents/Resources/alacritty.icns
#  touch /Applications/Alacritty.app
#)
brew install --yes --cask ghostty
brew install --yes --cask xquartz # -> requires password

# Install SFMono patched with the nerd font
# https://github.com/epk/SF-Mono-Nerd-Font
brew trust epk/epk \
  && brew tap epk/epk \
  && brew install --yes --cask font-sf-mono-nerd-font

# Install useful apps
brew install --yes --cask google-chrome
brew install --yes --cask safari-technology-preview
brew install --yes --cask mos
# brew install --yes --cask betterzip
brew install --yes --cask keka
brew install --yes --cask alfred
brew install --yes --cask thaw
# brew install --yes --cask bartender
brew install --yes --cask microsoft-office
brew install --yes --cask zotero
brew install --yes --cask slack
brew install --yes --cask homerow
brew trust AlexStrNik/Browserino \
  && brew tap AlexStrNik/Browserino \
  && brew install --yes browserino \
  && xattr -d -r com.apple.quarantine /Applications/Browserino.app

# Install personal useful apps
# https://www.microsoft.com/en-us/microsoft-365/blog/2025/02/28/the-next-chapter-moving-from-skype-to-microsoft-teams/
# brew install --yes --cask skype
brew install --yes --cask istat-menus
# brew install --yes --cask stats
# brew install --yes --cask teamviewer # -> requires password
# brew install --yes --cask alt-tab
brew install --yes --cask synology-drive
brew install --yes --cask openvpn-connect
brew install --yes --cask hazel
brew install --yes --cask dropbox
# brew install --yes --cask inkscape
brew install --yes --cask mactex # -> requires password
brew install --yes --cask mathpix-snipping-tool
brew install --yes --cask notion
# brew install --yes --cask transmission
# brew install --yes --cask swiftbar
# brew install --yes --cask paragon-ntfs
brew install --yes --cask iina
# https://www.popclip.app/kb/mas#but-what-about-installing-in-future-on-a-new-mac
brew install --yes --cask popclip

# Install virtualmachine engines
# brew install --yes --cask vmware-fusion
brew install --yes --cask parallels@17
# brew install --yes --cask virtualbox
# brew install --yes --cask vagrant
# brew install --yes --cask vagrant-manager

# Install container engines
# brew install --yes docker
# brew install --yes docker-compose
brew install --yes podman
brew install --yes podman-compose

## Install yabai
#brew install --yes koekeishiya/formulae/yabai
#echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 "$(brew --prefix)/bin/yabai") --load-sa" | \
#    sudo tee -a /private/etc/sudoers.d/yabai >/dev/null
## reinstall the scripting addition
#sudo yabai --uninstall-sa || true
#sudo yabai --install-sa || true
#yabai --start-service
## load the scripting addition
#killall Dock || true
#
## Install skhd
#brew install --yes koekeishiya/formulae/skhd
#skhd --start-service
#
## # Install uebersicht
## brew install --yes --cask ubersicht
## # install simplebar
## git clone https://github.com/Jean-Tinland/simple-bar $HOME/Library/Application\ Support/Übersicht/widgets/simple-bar
#
## Install sketchybar
#brew tap FelixKratz/formulae && brew install --yes sketchybar
#brew services start sketchybar
## install app font for sketchybar
#app_font_version=$("$DIR"/../helpers/gh_get_latest_release "kvndrsslr/sketchybar-app-font")
#curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/"${app_font_version}"/sketchybar-app-font.ttf \
#  -o "$HOME"/Library/Fonts/sketchybar-app-font.ttf
#curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/"${app_font_version}"/icon_map.sh \
#  -o "$DIR"/../../config/sketchybar/plugins/icon_map.sh


## free stuff
# mas install 1018899653  # HeliumLift -> Download it manually
# mas install 937984704   # Amphetamine
mas install 409183694   # Keynote
mas install 409201541   # Pages
mas install 409203825   # Numbers
# mas install 1295203466  # Microsoft Remote Desktop
mas install 1114196460  # Rocket Fuel
# mas install 414855915   # WinArchiver Lite
# mas install 1462114288  # Grammarly for Safari
# mas install 1445910651  # Dynamo
mas install 869223134   # KakaoTalk
# https://github.com/televator-apps/vimari/issues/304
# mas install 1480933944  # Vimari
mas install 1559269364  # Notion Web Clipper
mas install 1519867270  # Refined GitHub


## not free
# mas install 445189367   # PopClip (https://www.popclip.app/kb/mas)
# mas install 441258766   # Magnet
# mas install 461788075   # Movist
# mas install 577085396   # Unclutter
mas install 1231935892  # Unicorn Blocker:Adblock
mas install 1475628500  # Unicorn HTTPS
# mas install 922765270   # LiquidText


# Remove outdated versions from the cellar.
brew cleanup
