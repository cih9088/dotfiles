#!/usr/bin/env bash

################################################################
set -e

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `osxprep.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing brew..."
(
    # install brew for macos
    if [[ $platform == "OSX" ]]; then
        if [[ ! "$(command -v brew)" ]]; then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
        fi
    elif [[ $platform == "LINUX" ]]; then
        :
    else
        echo 'not defined'; exit 1
    fi
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "brew is installed" \
    "brew install is failed. use VERBOSE=YES for error message"

# install python, etc.
echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing prerequisites..."
(
    if [[ $platform == "OSX" ]]; then
        brew tap homebrew/bundle
        brew tap homebrew/core
        brew tap homebrew/cask
        brew install bash
        brew install python2
        brew install python
        brew install wget
        brew install pssh
        brew install coreutils
        brew install highlight
        brew install git
        brew install reattach-to-user-namespace
        brew cask install xquartz
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get install -y python-dev python-pip python3-dev python3-pip highlight xclip wget git
    else
        echo 'not defined'; exit 1
    fi
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "prerequisites are installed" \
    "prerequisites install is failed. use VERBOSE=YES for error message"

# do not udpate pip causing import error!
# sudo pip install --upgrade pip || true
# sudo pip2 intall --upgrade pip || true
# sudo pip3 install --upgrade pip || true
