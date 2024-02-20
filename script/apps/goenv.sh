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

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

setup_for_local() {
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
    ++ pushd ${GOENV_ROOT}
    ++ git fetch --all
    _LATEST_TAGS=$(git tag | grep -v '[a-z]' | sort -Vr | head -n 1)
    ++ git checkout "${_LATEST_TAGS}"
  fi
}

setup_for_system() {
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
      log_info "Not able to ${COMMAND} ${THIS} systemwide."
      setup_for_local "${COMMAND}"
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  "" "" version_func
