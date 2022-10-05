#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=python-env

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=isort

log_title "Prepare for ${THIS_HL}"

################################################################

setup_func_isort_local() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "install" ]; then
    ++ intelli_pip3 install isort
  elif [ "${COMMAND}" == "update" ]; then
    ++ intelli_pip3 install isort --force-reinstall --upgrade
  elif [ "${COMMAND}" == "remove" ]; then
    ++intelli_pip3 uninstall isort
  fi
}

version_func_isort() {
  $1 --version | tail -n 2 | awk '{print $2}'
}

main_script "${THIS}" setup_func_isort_local setup_func_isort_local version_func_isort \
  "latest"
