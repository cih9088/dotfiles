#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install up${Color_Off}"

UP_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release akavel/up)"
UP_VERSION=${1:-${UP_LATEST_VERSION##v}}
[[ ${UP_VERSION} != "v"* ]] && UP_VERSION="v${UP_VERSION}"
$(${PROJ_HOME}/script/check_release akavel/up ${UP_VERSION}) || exit $?
################################################################

setup_func_up_local() {
  force=$1
  cd $TMP_DIR

  install=no
  if [ -f ${HOME}/.local/bin/up ]; then
    if [ ${force} == 'true' ]; then
      rm -rf $HOME/.local/bin/up || true
      install=true
    fi
  else
    install=true
  fi

  if [ ${install} == 'true' ]; then
    if [[ $platform == "OSX" ]]; then
      wget https://github.com/akavel/up/releases/download/${UP_VERSION}/up-darwin
      chmod +x up
      yes | \cp -rf up-darwin $HOME/.local/bin/up
    elif [[ $platform == "LINUX" ]]; then
      wget https://github.com/akavel/up/releases/download/${UP_VERSION}/up
      chmod +x up
      yes | \cp -rf up $HOME/.local/bin/up
    fi
  fi
}

setup_func_up_system() {
  force=$1
  cd $TMP_DIR

  if [[ $platform == "OSX" ]]; then
    brew list up || brew install up
    if [ ${force} == 'true' ]; then
      brew upgrade up
    fi
  elif [[ $platform == "LINUX" ]]; then
    setup_func_up_local $force
  fi
}

version_func_up() {
  $1 --version 2>&1
}

main_script 'up' setup_func_up_local setup_func_up_system version_func_up
