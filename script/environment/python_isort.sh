#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=isort

log_title "Prepare to install ${THIS_HL}"

################################################################

setup_func_isort_local() {
  local FORCE="${1}"

  if [ ${FORCE} == 'true' ]; then
    intelli_pip3 install isort --force-reinstall --upgrade || exit $?
  else
    intelli_pip3 install isort || exit $?
  fi
}

version_func_isort() {
  $1 --version | tail -n 2 | awk '{print $2}'
}

main_script ${THIS} setup_func_isort_local setup_func_isort_local version_func_isort
