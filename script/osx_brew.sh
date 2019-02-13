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
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# Install GNU core utilities (those that come with OS X are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# brew install gawk
# brew install gnu-indent --with-default-names
# brew install gnu-tar --with-default-names
# brew install gnu-which --with-default-names
# brew install gnutls

# Install Bash 4.
brew install bash
brew tap homebrew/versions
brew install bash-completion2

# Install `wget` with IRI support.
brew install wget --with-iri

# Install ruby-build and rbenv
# brew install ruby-build
# brew install rbenv
# LINE='eval "$(rbenv init -)"'
# grep -q "$LINE" ~/.extra || echo "$LINE" >> ~/.extra

# Install more recent versions of some OS X tools.
# brew install vim --override-system-vi
brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh
# brew install homebrew/dupes/screen
# brew install homebrew/php/php55 --with-gmp

# Install other useful binaries.
brew install ack
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
# brew install p7zip
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

# Lxml and Libxslt
# brew install libxml2
# brew install libxslt
# brew link libxml2 --force
# brew link libxslt --force

# Core casks
# brew cask install --appdir="/Applications" alfred
brew cask install --appdir="/Applications" alacritty
brew cask install --appdir="/Applications" xquartz

# Misc casks
brew cask install --appdir="/Applications" google-chrome
brew cask install --appdir="/Applications" skype
brew cask install --appdir="/Applications" slack
brew cask install --appdir="/Applications" dropbox
brew cask install --appdir="/Applications" inkscape
brew cask install --appdir="/Applications" mactex
brew cask install --appdir="/Applications" docker
brew cask install --appdir="/Applications" betterzip
# brew cask install --appdir="/Applications" 1password
# brew cask install --appdir="/Applications" gimp
brew cask install --appdir="/Applications" mactex

# Install developer friendly quick look plugins; see https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzip qlimagesize webpquicklook suspicious-package quicklookase qlvideo


# mas
brew install mas

while true; do
    mas account >/dev/null 2>&1
    [[ $? == 0 ]] && break
    echo -n "Please signin Appstore manually and press any keys."
    read anykey
done

# free stuff
mas install 1278508951  # Trello
mas install 1018899653  # HeliumLift
mas install 937984704   # Amphetamine
mas install 409183694   # Keynote
mas install 409201541   # Pages
mas install 409203825   # Numbers
mas install 1295203466  # Microsoft Remote Desktop

# not free
mas install 445189367   # PopClip
mas install 441258766   # Magnet
mas install 461788075   # Movist


# Remove outdated versions from the cellar.
brew cleanup
