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

setup_func_terminfo_local() {
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
    ++ curl -LO --silent --show-error https://invisible-island.net/datafiles/current/terminfo.src.gz
    ++ gzip -d terminfo.src.gz
    ++ tic -x -o "${HOME}/.terminfo" terminfo.src
  fi
}

main_script "${THIS}" setup_func_terminfo_local setup_func_terminfo_local "" \
  "${DEFAULT_VERSION}"
