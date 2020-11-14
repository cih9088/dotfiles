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
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

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
# brew cask install alfred
brew cask install iterm2
brew cask install alacritty
brew cask install xquartz # -> requires password

# Misc casks
brew cask install google-chrome
brew cask install skype
brew cask install slack
brew cask install dropbox
brew cask install inkscape
brew cask install mactex # -> requires password
brew cask install docker
# brew cask install betterzip
brew cask install keka
brew cask install kekadefaultapp
brew cask install mathpix-snipping-tool
brew cask install notion
brew cask install transmission
brew cask install mos
brew cask install stats
brew cask install teamviewer # -> requires password
brew cask install vmware-fusion
brew cask install alt-tab
# brew cask install microsoft-office
# brew cask install 1password
# brew cask install gimp

# Install developer friendly quick look plugins; see https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv qlimagesize webpquicklook suspicious-package quicklookase qlvideo
xattr -d -r com.apple.quarantine ~/Library/QuickLook

# install SFMono patched with the nerd font
# https://github.com/epk/SF-Mono-Nerd-Font
brew tap epk/epk
brew cask install font-sf-mono-nerd-font

# vagrant and virtualbox
brew cask install virtualbox
brew cask install vagrant
brew cask install vagrant-manager

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
mas install 975937182   # Fantastical


## not free
mas install 445189367   # PopClip
mas install 441258766   # Magnet
mas install 461788075   # Movist
mas install 1475628500  # Unicorn HTTPS
mas install 1231935892  # Unicorn Blocker:Adblock
mas install 922765270   # LiquidText


# Remove outdated versions from the cellar.
brew cleanup


# iterm2 config
if [[ -e /Applications/iTerm.app ]]; then
    # Specify the preferences directory
    defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/config/iterm2"
    # Tell iTerm2 to use the custom preferences in the directory
    defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
fi
