#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

setup_func_bpytop_local() {
  local FORCE=$1

  if [ ${FORCE} == 'true' ]; then
    intelli_pip3 install bpytop --force-reinstall --upgrade || exit $?
  else
    intelli_pip3 install bpytop || exit $?
  fi
}

setup_func_bpytop_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list bpytop || brew install bpytop || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade bpytop || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [ ${FORCE} == 'true' ]; then
      sudo pip3 install bpytop --upgrade --force-reinstall || exit $?
    else
      sudo pip3 install bpytop || exit $?
    fi
  fi
}

version_func_bpytop() {
  $1 --version 2>&1
}

main_script ${THIS} setup_func_bpytop_local setup_func_bpytop_system version_func_bpytop \
  "${DEFAULT_VERSION}"
