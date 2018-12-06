#!/bin/bash

case "$OSTYPE" in
    solaris*) platform="SOLARIS" ;;
    darwin*)  platform="OSX" ;;
    linux*)   platform="LINUX" ;;
    bsd*)     platform="BSD" ;;
    msys*)    platform="WINDOWS" ;;
    *)        platform="unknown: $OSTYPE" ;;
esac

# install brew for macos
if [[ $platform == "OSX" ]]; then
    if [[ -x "$(hash brew)" ]]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
elif [[ $platform == "LINUX" ]]; then
    :
else
    echo 'not defined'; exit 1
fi

# install python, etc.
echo
echo '[*] install python, etc.'
if [[ $platform == "OSX" ]]; then
    brew bundle --file=- <<EOS
brew "python2"
brew "python"
brew "wget"
brew "pssh"
brew "coreutils"
brew "highlight"
brew "git"
EOS
elif [[ $platform == "LINUX" ]]; then
    sudo apt-get install python-dev python-pip python3-dev python3-pip highlight xclip wget git
else
    echo 'not defined'; exit 1
fi

# do not udpate pip causing import error!
# sudo pip install --upgrade pip || true
# sudo pip2 intall --upgrade pip || true
# sudo pip3 install --upgrade pip || true
