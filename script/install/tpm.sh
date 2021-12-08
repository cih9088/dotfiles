#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

log_title "Prepare to ${BOLD}${UNDERLINE}install ${THIS}${NC}"

###############################################################

setup_func() {
  local FORCE="${1}"

  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf "$HOME/.tmux/plugins/tpm" || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm || exit $?
  fi
}

main_script ${THIS} setup_func setup_func ""
