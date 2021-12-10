#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="nvbn/thefuck"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH} || exit $?)"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_thefuck_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ ${FORCE} == 'true' ]; then
    pip3 install thefuck==${VERSION} --user --force-reinstall --upgrade || exit $?
  else
    pip3 install thefuck==${VERSION} --user || exit $?
  fi
}

setup_func_thefuck_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list thefuck || brew install thefuck || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade thefuck || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [ ${FORCE} == 'true' ]; then
      sudo pip3 install thefuck --upgrade --force-reinstall || exit $?
    else
      sudo pip3 install thefuck || exit $?
    fi
  fi
}

version_func_thefuck() {
  $1 --version 2>&1
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_thefuck_local setup_func_thefuck_system version_func_thefuck \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
