#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install thefuck${Color_Off}"

# if asdf is installed
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
export PATH="${HOME}/.pyenv/bin:$PATH"
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true

################################################################

setup_func_thefuck_local() {
  force=$1
  cd $TMP_DIR

  if [ ${force} == 'true' ]; then
    pip install thefuck --user --force-reinstall --upgrade
  else
    pip install thefuck --user
  fi
}

setup_func_thefuck_system() {
  force=$1
  cd $TMP_DIR

  if [[ $platform == "OSX" ]]; then
    brew list thefuck || brew install thefuck
    if [ ${force} == 'true' ]; then
      brew upgrade thefuck
    fi
  elif [[ $platform == "LINUX" ]]; then
    if [ ${force} == 'true' ]; then
      sudo pip install thefuck --upgrade --force-reinstall
    else
      sudo pip install thefuck
    fi
  fi
}

version_func_thefuck() {
  $1 --version 2>&1
}

main_script 'thefuck' setup_func_thefuck_local setup_func_thefuck_system version_func_thefuck
