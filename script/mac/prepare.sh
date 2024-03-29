#!/usr/bin/env bash
# https://github.com/donnemartin/dev-setup/blob/master/osxprep.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `osxprep.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Update the OS and Install Xcode Tools
log_title "Update OSX.  If this requires a restart, run the script again."
# Install all available updates
sudo softwareupdate -ia --verbose
# Install only recommended available updates
#sudo softwareupdate -ir --verbose

# Install rosetta2
is_apple_silicon=false
arch="$(uname -m)"
if [[ "$arch" = x86_64* ]]; then
  if [[ "$(uname -a)" = *ARM64* ]]; then
    is_apple_silicon=true
  fi
elif [[ "$arch" = arm* ]]; then
  is_apple_silicon=true
fi
if [ $is_apple_silicon == true ]; then
  log_title "Install Rosetta2."
  softwareupdate --install-rosetta --agree-to-license
fi

# Install Xcode command line tools
log_title "Install Xcode Command Line Tools"
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
sleep 10
# https://stackoverflow.com/a/41613532
# wait until install is finished
pid=$(ps aux | grep -i 'command line' | grep -v grep | awk '{print $2}')
lsof -p $pid +r 1 &>/dev/null
