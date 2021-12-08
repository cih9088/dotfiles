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
  if [ -x "$(command -v ${PYENV_ROOT}/bin/pyenv)" ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf ${PYENV_ROOT} || true
      DO_INSTALL='true'
    fi
  else
    DO_INSTALL='true'
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    curl https://pyenv.run | bash
    git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git \
      ${PYENV_ROOT}/plugins/pyenv-virtualenvwrapper || exit $?
    git clone https://github.com/momo-lab/xxenv-latest.git \
      ${PYENV_ROOT}/plugins/xxenv-latest || exit $?
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list pyenv || brew install pyenv || exit $?
    brew list pyenv-virtualenv || brew install pyenv-virtualenv || exit $?
    brew list pyenv-virtualenvwrapper || brew install pyenv-virtualenvwrapper || exit $?
    [ -d ${PYENV_ROOT}/plugins/xxenv-latest ] ||
      git clone https://github.com/momo-lab/xxenv-latest.git \
      ${PYENV_ROOT}/plugins/xxenv-latest

    if [ ${FORCE} == 'true' ]; then
      brew upgrade pyenv || exit $?
      brew upgrade pyenv-virtualenv || exit $?
      brew upgrade pyenv-virtualenvwrapper || exit $?
      rm -rf ${PYENV_ROOT}/plugins/xxenv-latest || true
      git clone https://github.com/momo-lab/xxenv-latest.git \
        ${PYENV_ROOT}/plugins/xxenv-latest
    fi
  else
    setup_func_local ${FORCE}
  fi

}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script ${THIS} setup_func_local setup_func_system version_func
