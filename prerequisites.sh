#!/bin/bash

case "$OSTYPE" in
    solaris*) platform='SOLARIS' ;;
    darwin*)  platform='OSX' ;;
    linux*)   platform='LINUX' ;;
    bsd*)     platform='BSD' ;;
    msys*)    platform='WINDOWS' ;;
    *)        platform='unknown: $OSTYPE' ;;
esac

# install brew for macos
if [[ $platform == "OSX" ]]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
elif [[ $platform == "LINUX" ]]; then
    :
else
    echo 'not defined'; exit 1
fi

# install python, etc.
echo
echo '[*] install python, etc.'
if [[ $platform == "OSX" ]]; then
    brew install python2
    brew install python
    brew install wget
    brew install reattach-to-user-namespace
elif [[ $platform == "LINUX" ]]; then
    sudo apt-get install python-dev python-pip python3-dev python3-pip
else
    echo 'not defined'; exit 1
fi

sudo pip install --upgrade pip
sudo pip3 install --upgrade pip
