#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install rg${Color_Off}"

RG_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release BurntSushi/ripgrep)"
RG_VERSION=${1:-${RG_LATEST_VERSION##v}}
$(${PROJ_HOME}/script/check_release BurntSushi/ripgrep ${RG_VERSION}) || exit $?
################################################################

setup_func_rg_local() {
  force=$1
  cd $TMP_DIR

  install=no
  if [ -f ${HOME}/.local/bin/rg ]; then
    if [ ${force} == 'true' ]; then
      rm -rf $HOME/.local/bin/rg || true
      rm -rf $HOME/.local/man/man1/rg.1 || true
      install=true
    fi
  else
    install=true
  fi

  if [ ${install} == 'true' ]; then
    if [[ $platform == "OSX" ]]; then
      wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
      tar -xvzf ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
      cd ripgrep-${RG_VERSION}-x86_64-apple-darwin
      yes | \cp -rf rg $HOME/.local/bin
      yes | \cp -rf doc/rg.1 $HOME/.local/man/man1
    elif [[ $platform == "LINUX" ]]; then
      wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
      tar -xvzf ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
      cd ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl
      yes | \cp -rf rg $HOME/.local/bin
      yes | \cp -rf doc/rg.1 $HOME/.local/man/man1
    fi
  fi
}

setup_func_rg_system() {
  force=$1
  cd $TMP_DIR

  if [[ $platform == "OSX" ]]; then
    brew list ripgrep || brew install ripgrep
    if [ ${force} == 'true' ]; then
      brew upgrade ripgrep
    fi
  elif [[ $platform == "LINUX" ]]; then
    cd $TMP_DIR
    wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
    sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
  fi
}

version_func_rg() {
  $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'rg' setup_func_rg_local setup_func_rg_system version_func_rg
