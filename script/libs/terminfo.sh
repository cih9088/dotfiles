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

setup_for_local() {
  local COMMAND="${1:-skip}"

  if [[ "remove update" == *"${COMMAND}"* ]]; then
    if [ -d "${HOME}/.terminfo" ]; then
      rm -rf "${HOME}/.terminfo"
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    ++ curl -LO --show-error https://invisible-island.net/datafiles/current/terminfo.src.gz
    ++ gzip -d terminfo.src.gz
    ++ tic -x -o "${HOME}/.terminfo" terminfo.src

    # https://github.com/htop-dev/htop/issues/251#issuecomment-719080271
    ++ curl -LO https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color
    ++ tic -x -o "${HOME}/.terminfo" tmux-256color
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  if [[ "install update"  == *"${COMMAND}"* ]]; then
    ++ curl -LO --show-error https://invisible-island.net/datafiles/current/terminfo.src.gz
    ++ gzip -d terminfo.src.gz
    ++ tic -x -o /usr/share/terminfo terminfo.src

    # https://github.com/htop-dev/htop/issues/251#issuecomment-719080271
    ++ curl -LO https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color
    ++ tic -x -o /usr/share/terminfo tmux-256color
  elif [ "${COMMAND}" == "remove" ]; then
    log_error "${THIS_HL} is not removable."
    exit 1
  fi
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  "" "" ""
