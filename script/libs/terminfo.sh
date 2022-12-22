#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

setup_func_local() {
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
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  if [[ "install update"  == *"${COMMAND}"* ]]; then
    ++ curl -LO --show-error https://invisible-island.net/datafiles/current/terminfo.src.gz
    ++ gzip -d terminfo.src.gz
    ++ tic -x -o /usr/share/terminfo terminfo.src
  elif [ "${COMMAND}" == "remove" ]; then
    log_error "${THIS_HL} is not removable."
    exit 1
  fi
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}"
