#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=python-env

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${NC}"
THIS_CMD=black

log_title "Prepare for ${THIS_HL}"

################################################################

setup_func_black_local() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "install" ]; then
    ++ intelli_pip3 install black
  elif [ "${COMMAND}" == "update" ]; then
    ++ intelli_pip3 install black --force-reinstall --upgrade
  elif [ "${COMMAND}" == "remove" ]; then
    ++ intelli_pip3 uninstall black
  fi
}

version_func_black() {
  $1 --version | awk '{print $2}'
}

main_script "${THIS}" setup_func_black_local setup_func_black_local version_func_black \
  "latest"
