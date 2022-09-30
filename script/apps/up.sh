#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="akavel/up"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_up_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f ${PREFIX}/bin/up ]; then
      rm -rf ${PREFIX}/bin/up || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f ${PREFIX}/bin/up ]; then

      case ${PLATFORM} in
        OSX )
          ++ curl -LO https://github.com/akavel/up/releases/download/${VERSION}/up-darwin
          ++ chmod +x up
          \cp -rf up-darwin ${PREFIX}/bin/up
          ;;
        LINUX )
          ++ curl -LO https://github.com/akavel/up/releases/download/${VERSION}/up
          ++ chmod +x up
          \cp -rf up ${PREFIX}/bin/up
          ;;
      esac
    fi
  fi
}

setup_func_up_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list up >/dev/null 2>&1 && ++ brew uninstall up
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list up >/dev/null 2>&1 || ++ brew install up
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade up
      fi
      ;;
    LINUX)
      log_error "No package in repository. Please install it in local mode"
      exit 1
      ;;
  esac
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_up_local setup_func_up_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
