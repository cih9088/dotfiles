#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="akavel/up"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_up_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -f ${PREFIX}/bin/up ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf ${PREFIX}/bin/up || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    if [[ ${PLATFORM} == "OSX" ]]; then
      wget https://github.com/akavel/up/releases/download/${VERSION}/up-darwin || exit $?
      chmod +x up
      \cp -rf up-darwin ${PREFIX}/bin/up
    elif [[ ${PLATFORM} == "LINUX" ]]; then
      wget https://github.com/akavel/up/releases/download/${VERSION}/up || exit $?
      chmod +x up
      \cp -rf up ${PREFIX}/bin/up
    fi
  fi
}

setup_func_up_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list up || brew install up || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade up || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    setup_func_up_local $FORCE
  fi
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_up_local setup_func_up_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
