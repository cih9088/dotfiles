#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  if [ "${COMMAND}" == "remove" ]; then
    if [ -x "$(command -v ${PYENV_ROOT}/bin/pyenv)" ]; then
      rm -rf ${PYENV_ROOT} || true
    fi
  elif [ "${COMMAND}" == "install" ]; then
    curl https://pyenv.run | bash
    ++ git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git \
      ${PYENV_ROOT}/plugins/pyenv-virtualenvwrapper
    ++ git clone https://github.com/momo-lab/xxenv-latest.git \
      ${PYENV_ROOT}/plugins/xxenv-latest
  elif [ "${COMMAND}" == "update" ]; then
    ++ ${PYENV_ROOT}/bin/pyenv update
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list pyenv >/dev/null 2>&1 && ++ brew uninstall pyenv
        brew list pyenv-virtualenv >/dev/null 2>&1 && ++ brew uninstall pyenv-virtualenv
        brew list pyenv-virtualenvwrapper >/dev/null 2>&1 && ++ brew uninstall pyenv-virtualenvwrapper
        [ -d ${PYENV_ROOT} ] && rm -rf ${PYENV_ROOT}
      elif [ "${COMMAND}" == "install" ]; then
        brew list pyenv >/dev/null 2>&1 || ++ brew install pyenv
        brew list pyenv-virtualenv >/dev/null 2>&1 || ++ brew install pyenv-virtualenv
        brew list pyenv-virtualenvwrapper >/dev/null 2>&1 || ++ brew install pyenv-virtualenvwrapper
        [ ! -d ${PYENV_ROOT}/plugins/xxenv-latest ] &&
          git clone https://github.com/momo-lab/xxenv-latest.git \
          ${PYENV_ROOT}/plugins/xxenv-latest
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade pyenv
        ++ brew upgrade pyenv-virtualenv
        ++ brew upgrade pyenv-virtualenvwrapper
        [ -d ${PYENV_ROOT}/plugins/xxenv-latest ] && (
            cd ${PYENV_ROOT}/plugins/xxenv-latest; git pull
          )
      fi
      ;;
    LINUX)
      log_error "Not able to install systemwide."
      exit 1
      ;;
  esac

}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script ${THIS} setup_func_local setup_func_system version_func
