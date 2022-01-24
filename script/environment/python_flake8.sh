#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=flake8

log_title "Prepare to install ${THIS_HL}"

################################################################

setup_func_flake8_local() {
  local FORCE="${1}"

  if [ ${FORCE} == 'true' ]; then
    intelli_pip3 install flake8 --force-reinstall --upgrade || exit $?
  else
    intelli_pip3 install flake8 || exit $?
  fi
}

version_func_flake8() {
  $1 --version | head -n 1 | awk '{print $1}'
}

main_script ${THIS} setup_func_flake8_local setup_func_flake8_local version_func_flake8
