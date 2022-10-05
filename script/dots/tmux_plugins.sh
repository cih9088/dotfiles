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

  if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
    log_error "tpm is not found in ${HOME}/.tmux/plugins. Please install tpm first."
    exit 1
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ "${HOME}/.tmux/plugins/tpm/scripts/clean_plugins.sh"
  elif [ "${COMMAND}" == "install" ]; then
    ++ "${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh"
  elif [ "${COMMAND}" == "update" ]; then
    ++ "${HOME}/.tmux/plugins/tpm/scripts/update_plugin.sh" "" all
  fi
}

main_script ${THIS} setup_func "" "" "NONE"
