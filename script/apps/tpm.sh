#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

setup_func() {
  local COMMAND="${1:-skip}"

  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${HOME}/.tmux/plugins/tpm ]; then
      rm -rf ${HOME}/.tmux/plugins/tpm || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  elif [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d ${HOME}/.tmux/plugins/tpm ]; then
      ++ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
  fi
}

main_script ${THIS} setup_func setup_func
