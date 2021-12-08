#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"
################################################################

setup_func_ranger_local() {
  local FORCE=$1
  local DO_INSTALL=no

  if [ -f ${HOME}/.local/bin/ranger ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf $HOME/.local/src/ranger || true
      rm -rf $HOME/.local/bin/ranger || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    git clone https://github.com/ranger/ranger.git $HOME/.local/src/ranger
    $HOME/.local/src/ranger/ranger.py --copy-config=all
    ln -sf $HOME/.local/src/ranger/ranger.py $HOME/.local/bin/ranger
  fi
}

setup_func_ranger_system() {
  setup_func_ranger_local $1
}

version_func_ranger() {
  $1 --version | head -1 | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'
}

main_script ${THIS} setup_func_ranger_local setup_func_ranger_system version_func_ranger
