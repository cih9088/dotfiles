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

setup_func_local() {
  local FORCE=$1
  local DO_INSTALL=no

  if [ -f "${HOME}/.asdf/asdf.sh" ]; then
    if [ ${FORCE} == 'true' ]; then
      DO_INSTALL='true'
    fi
  else
    DO_INSTALL='true'
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
      . $HOME/.asdf/asdf.sh
      asdf update
    else
      git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf || exit $?
      pushd ${HOME}/.asdf
      git checkout "$(git describe --abbrev=0 --tags)" || exit $?
      popd
    fi
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list asdf || brew install asdf || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade asdf || exit $?
    fi
  else
    setup_func_local ${FORCE}
  fi
}

version_func() {
  $1 version
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}"
