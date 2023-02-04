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

  if [ "${COMMAND}" == "update" ]; then
    if [ -d "${HOME}/.tmux/plugins/tpm" ]; then
      ++ pushd "${HOME}/.tmux/plugins/tpm"
      ++ git pull
      ++ popd
    else
      log_error "${THIS_HL} is not installed. Please install it before update it."
      exit 1
    fi
  elif [ "${COMMAND}" == "install" ]; then
    if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
      ++ git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    fi
  elif [ "${COMMAND}" == "remove" ]; then
    rm -rf "${HOME}/.tmux/plugins/tpm" || true
  fi
}

main_script "${THIS}" setup_func ""
