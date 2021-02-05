#!/usr/bin/env bash

# copied from https://github.com/donnemartin/dev-setup/blob/master/brew.sh

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi


# mas
brew install mas
while true; do
  mas account >/dev/null 2>&1
  [[ $? == 0 ]] && break
  echo -n "Please signin Appstore manually and press any keys."
  read anykey
done

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
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed
brew install gawk
# brew install gnu-indent --with-default-names
# brew install gnu-tar --with-default-names
# brew install gnu-which --with-default-names
# brew install gnutls

# Install Bash 5
brew install bash
# brew install bash-completion2
# We installed the new shell, now we have to activate it
# echo "Adding the newly installed shell to the list of allowed shells"
# Prompts for password
# sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
# Change to the new shell, prompts for password
# chsh -s /usr/local/bin/bash

# Install `wget` with IRI support.
# brew install wget --with-iri
brew install wget

brew install python
# create symlink manually
# https://github.com/Homebrew/homebrew-core/issues/16212
ln -snf $(brew --prefix)/bin/python3 $(brew --prefix)/bin/python
ln -snf $(brew --prefix)/bin/python3-config $(brew --prefix)/bin/python-config
ln -snf $(brew --prefix)/bin/pip3 $(brew --prefix)/bin/pip
ln -snf $(brew --prefix)/bin/wheel3 $(brew --prefix)/bin/wheel
ln -snf $(brew --prefix)/bin/pydoc3 $(brew --prefix)/bin/pydoc
ln -snf $(brew --prefix)/bin/pydoc3 $(brew --prefix)/bin/pydoc

# Install ruby-build and rbenv
# brew install ruby-build
# brew install rbenv
# LINE='eval "$(rbenv init -)"'
# grep -q "$LINE" ~/.extra || echo "$LINE" >> ~/.extra

# Install more recent versions of some OS X tools.
# brew install vim --override-system-vi
brew install grep
brew install openssh
brew install esolitos/ipa/sshpass
brew install pssh
# brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
# brew install homebrew/dupes/screen
# brew install homebrew/php/php55 --with-gmp

# Install other useful binaries.
# brew install ack
# brew install dark-mode
#brew install exiv2
brew install git
brew install watch
brew install gzip
# brew install git-lfs
# brew install git-flow
# brew install git-extras
# brew install hub
# brew install imagemagick --with-webp
# brew install lua
# brew install lynx
brew install p7zip
# brew install pigz
brew install pv
# brew install rename
# brew install rhino
# brew install speedtest_cli
brew install ssh-copy-id
# brew install tree
# brew install webkit2png
# brew install zopfli
# brew install pkg-config libffi
brew install pandoc
brew install mosh
brew install htop
brew install awscli
brew install jq

# Lxml and Libxslt
# brew install libxml2
# brew install libxslt
# brew link libxml2 --force
# brew link libxslt --force

# Core casks
brew install --cask iterm2
brew install --cask alacritty
# download big sur icon for alacritty
[ -e /Applications/Alacritty.app ] && (
wget 'https://www.dropbox.com/s/0i4ez0el7paksg3/Alacritty.icns' -O /Applications/Alacritty.app/Contents/Resources/alacritty.icns
touch /Applications/Alacritty.app
)
brew install --cask xquartz # -> requires password

# Install developer friendly quick look plugins; see https://github.com/sindresorhus/quick-look-plugins
brew install --cask qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv qlimagesize webpquicklook suspicious-package quicklookase qlvideo
xattr -d -r com.apple.quarantine ~/Library/QuickLook

# install SFMono patched with the nerd font
# https://github.com/epk/SF-Mono-Nerd-Font
brew tap epk/epk
brew install --cask font-sf-mono-nerd-font

# Misc casks
brew install --cask google-chrome
brew install --cask skype
brew install --cask mos
# brew install --cask betterzip
brew install --cask keka
# brew install --cask stats
brew install --cask eul
brew install --cask teamviewer # -> requires password
brew install --cask vmware-fusion
brew install --cask alt-tab
brew install --cask alfred
brew install --cask bartender
brew install --cask mounty
brew install --cask hazel
brew install --cask microsoft-office

brew install --cask
brew install --cask refined-github-safari
brew install --cask dropbox
brew install --cask slack
brew install --cask inkscape
brew install --cask mactex # -> requires password
brew install --cask docker
brew install --cask mathpix-snipping-tool
brew install --cask notion
brew install --cask transmission
# brew install --cask bitbar
brew tap melonamin/formulae
brew install swiftbar
brew tap homebrew/cask-versions
brew install safari-technology-preview
# brew install --cask fantastical
# brew install --cask 1password
# brew install --cask gimp

# vagrant and virtualbox
brew install --cask virtualbox
brew install --cask vagrant
brew install --cask vagrant-manager

# install yabai
brew install koekeishiya/formulae/yabai
echo "$(whoami) ALL = (root) NOPASSWD: /usr/local/bin/yabai --load-sa" |\
    sudo tee -a /private/etc/sudoers.d/yabai >/dev/null
# reinstall the scripting addition
sudo yabai --uninstall-sa || true
sudo yabai --install-sa || true
brew services start yabai
# load the scripting addition
killall Dock || true

# install skhd
brew install koekeishiya/formulae/skhd
brew services start skhd

# install spacebar
brew install cmacrae/formulae/spacebar
brew services start spacebar

## free stuff
mas install 1018899653  # HeliumLift
#mas install 937984704   # Amphetamine
mas install 409183694   # Keynote
mas install 409201541   # Pages
mas install 409203825   # Numbers
mas install 1295203466  # Microsoft Remote Desktop
mas install 1114196460  # Rocket Fuel
# mas install 414855915   # WinArchiver Lite
mas install 869223134   # KakaoTalk
mas install 1445910651  # Dynamo
mas install 1462114288  # Grammarly for Safari
mas install 1480933944  # Vimari

## not free
mas install 445189367   # PopClip
mas install 441258766   # Magnet
mas install 461788075   # Movist
mas install 1475628500  # Unicorn HTTPS
mas install 1231935892  # Unicorn Blocker:Adblock
mas install 922765270   # LiquidText
mas install 577085396   # Unclutter


# Remove outdated versions from the cellar.
brew cleanup


# iterm2 config
if [[ -e /Applications/iTerm.app ]]; then
  # Specify the preferences directory
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/config/iterm2"
  # Tell iTerm2 to use the custom preferences in the directory
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

  # copy script
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  cp -r $DIR/../config/iterm2/AutoLaunch ~/Library/Application\ Support/iterm2/Scripts
fi
