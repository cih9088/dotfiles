#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"
################################################################

setup_func_local() {
  local FORCE=$1

  local DO_INSTALL=no
  if [ -x "$(command -v ${GOENV_ROOT}/bin/goenv)" ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf ${GOENV_ROOT} || true
      DO_INSTALL='true'
    fi
  else
    DO_INSTALL='true'
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    git clone https://github.com/syndbg/goenv.git \
      ${GOENV_ROOT} || exit $?
    git clone https://github.com/momo-lab/xxenv-latest.git \
      ${GOENV_ROOT}/plugins/xxenv-latest || exit $?
  fi
}

setup_func_system() {
  local FORCE=$1

  # https://github.com/syndbg/goenv/issues/80
  # no stable version is released yet
  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list goenv || brew install --HEAD goenv || exit $?
    [ -d ${GOENV_ROOT}/plugins/xxenv-latest ] ||
      git clone https://github.com/momo-lab/xxenv-latest.git \
      ${GOENV_ROOT}/plugins/xxenv-latest

    if [ ${FORCE} == 'true' ]; then
      brew upgrade --fetch-HEAD goenv || exit $?
      rm -rf ${GOENV_ROOT}/plugins/xxenv-latest || true
      git clone https://github.com/momo-lab/xxenv-latest.git \
        ${GOENV_ROOT}/plugins/xxenv-latest
    fi
  else
    setup_func_local ${FORCE}
  fi

}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script ${THIS} setup_func_local setup_func_system version_func
