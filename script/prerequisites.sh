#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing brew..."
(
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
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "brew is installed" \
    "brew install is failed. use VERBOSE=YES for error message"

# install python, etc.
echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing prerequisites..."
(
    if [[ $platform == "OSX" ]]; then
        brew bundle --file=- <<EOS
tap "homebrew/bundle"
tap "homebrew/core"
tap "homebrew/cask"
brew "bash"
brew "python2"
brew "python"
brew "wget"
brew "pssh"
brew "coreutils"
brew "highlight"
brew "git"
brew "reattach-to-user-namespace"
cask "xquartz"
EOS
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get install python-dev python-pip python3-dev python3-pip highlight xclip wget git
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
