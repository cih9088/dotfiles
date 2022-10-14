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
    if [ -x "$(command -v ${GOENV_ROOT}/bin/goenv)" ]; then
      rm -rf ${GOENV_ROOT} || true
    fi
  elif [ "${COMMAND}" == "install" ]; then
    ++ git clone https://github.com/syndbg/goenv.git \
      ${GOENV_ROOT}
    ++ git clone https://github.com/momo-lab/xxenv-latest.git \
      ${GOENV_ROOT}/plugins/xxenv-latest
  elif [ "${COMMAND}" == "update" ]; then
    ++ ${GOENV_ROOT}/bin/goenv update
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list goenv >/dev/null 2>&1 && ++ brew uninstall goenv
        [ -d ${GOENV_ROOT} ] && rm -rf ${GOENV_ROOT}
      elif [ "${COMMAND}" == "install" ]; then
        brew list goenv >/dev/null 2>&1 || ++ brew install goenv
        [ ! -d ${GOENV_ROOT}/plugins/xxenv-latest ] &&
          git clone https://github.com/momo-lab/xxenv-latest.git \
          ${GOENV_ROOT}/plugins/xxenv-latest
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade goenv
        [ -d ${GOENV_ROOT}/plugins/xxenv-latest ] && (
            cd ${GOENV_ROOT}/plugins/xxenv-latest; git pull
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
