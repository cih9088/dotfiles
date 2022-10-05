#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=python-env

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=flake8

log_title "Prepare for ${THIS_HL}"

################################################################

setup_func_flake8_local() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "install" ]; then
    ++ intelli_pip3 install flake8
  elif [ "${COMMAND}" == "update" ]; then
    ++ intelli_pip3 install flake8 --force-reinstall --upgrade
  elif [ "${COMMAND}" == "remove" ]; then
    ++ intelli_pip3 uninstall flake8
  fi
}

version_func_flake8() {
  $1 --version | head -n 1 | awk '{print $1}'
}

main_script "${THIS}" setup_func_flake8_local setup_func_flake8_local version_func_flake8 \
  "latest"
