#!/usr/bin/env bash

################################################################
set -e

# Ask for the administrator password upfront
sudo -v

# Always verbose output
VERBOSE=true

# Keep-alive: update existing `sudo` time stamp until `osxprep.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

# install brew for macos
if [[ $platform == "OSX" ]]; then
  echo
  [[ ${VERBOSE} == "true" ]] || start_spinner "Installing brew..."
  (
    if [[ ! "$(command -v brew)" ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
  ) >&3 2>&4 || exit_code="$?" && true
  stop_spinner "${exit_code}" \
    "brew is installed" \
    "brew install is failed. use VERBOSE=true for error message"
fi

# install python, etc.
echo
[[ ${VERBOSE} == "true" ]] || start_spinner "Installing prerequisites..."
(
  if [[ $platform == "OSX" ]]; then
    brew tap homebrew/bundle
    brew tap homebrew/core
    brew tap homebrew/cask

    brew install bash

    # brew install python@2 -> python2 is not supported anymore
    brew install python
    # create symlink manually
    # https://github.com/Homebrew/homebrew-core/issues/16212
    ln -snf $(brew --prefix)/bin/python3 $(brew --prefix)/bin/python
    ln -snf $(brew --prefix)/bin/python3-config $(brew --prefix)/bin/python-config
    ln -snf $(brew --prefix)/bin/pip3 $(brew --prefix)/bin/pip
    ln -snf $(brew --prefix)/bin/wheel3 $(brew --prefix)/bin/wheel
    ln -snf $(brew --prefix)/bin/pydoc3 $(brew --prefix)/bin/pydoc
    ln -snf $(brew --prefix)/bin/pydoc3 $(brew --prefix)/bin/pydoc

    # pyenv
    brew install openssl readline sqlite3 xz zlib

    brew install wget
    brew install curl
    brew install pssh
    brew install coreutils
    brew install highlight
    brew install git
    brew install reattach-to-user-namespace
    brew install cmake

    brew install --cask xquartz

  elif [[ $platform == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      # basic
      sudo apt-get -y install python-dev python-pip python3-dev python3-pip highlight \
        xclip wget git cmake bsdmainutils curl
      # zsh, tmux
      sudo apt-get -y install libncurses5-dev libncursesw5-dev
      # pyenv
      sudo apt-get -y install make build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev \
        xz-utils tk-dev libffi-dev liblzma-dev python-openssl
    elif [[ $FAMILY == "RHEL" ]]; then
      # basic
      sudo dnf install -y python3 python2 highlight \
        xclip wget git cmake curl
      # zsh, tmux
      sudo dnf install -y ncurses-devel
      # pyenv
      sudo dnf install -y gcc zlib-devel bzip2 bzip2-devel \
        readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
      # treesitter
      sudo dnf install -y gcc-c++ libstdc++-devel

      sudo alternatives --set python /usr/bin/python3
      sudo alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
    fi
  else
    echo 'not defined'; exit 1
  fi
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
  "prerequisites are installed" \
  "prerequisites install is failed. use VERBOSE=true for error message"
