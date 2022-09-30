#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  if [ "${COMMAND}" == "remove" ]; then
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
      chown -R $(whoami) ${HOME}/.asdf
      rm -rf ${HOME}/.asdf || true
    fi
  elif [ "${COMMAND}" == "install" ]; then
    if [ ! -f "${HOME}/.asdf/asdf.sh" ]; then
      ++ git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf
      ++ pushd ${HOME}/.asdf
      ++ git checkout "$(git describe --abbrev=0 --tags)"
      ++ popd
    fi
  elif [ "${COMMAND}" == "update" ]; then
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
      . $HOME/.asdf/asdf.sh
      ++ asdf update
      ++ asdf plugin update --all
    else
      log_error "${THIS_HL} is not installed. Please install it before update it."
      exit 1
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list asdf >/dev/null 2>&1 && ++ brew uninstall asdf
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list asdf >/dev/null 2>&1 || ++ brew install asdf
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade asdf
      fi
      ;;
    LINUX)
      log_error "No package in repository. Please install it in local mode"
      exit 1
      ;;
  esac
}

version_func() {
  $1 version
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}"
