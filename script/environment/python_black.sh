#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=black

log_title "Prepare to install ${THIS_HL}"

################################################################

setup_func_black_local() {
  local FORCE="${1}"

  if [ ${FORCE} == 'true' ]; then
    intelli_pip3 install black --force-reinstall --upgrade || exit $?
  else
    intelli_pip3 install black || exit $?
  fi
}

version_func_black() {
  $1 --version | awk '{print $2}'
}

main_script ${THIS} setup_func_black_local setup_func_black_local version_func_black
