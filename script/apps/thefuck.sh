#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="nvbn/thefuck"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH} || exit $?)"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_thefuck_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  if [ "${COMMAND}" == "remove" ]; then
    intelli_pip3 uninstall --yes thefuck || exit $?
  elif [ "${COMMAND}" == "install" ]; then
    intelli_pip3 install thefuck=="${VERSION}" || exit $?
  elif [ "${COMMAND}" == "update" ]; then
    intelli_pip3 install --force-reinstall --upgrade thefuck=="${VERSION}" || exit $?
  fi
}

setup_func_thefuck_system() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    case ${PLATFORM} in
      OSX )
        brew list thefuck >/dev/null 2>&1 && brew uninstall thefuck
        ;;
      LINUX )
        sudo pip3 uninstall --yes thefuck || exit $?
        ;;
    esac
  elif [ "${COMMAND}" == "install" ]; then
    case ${PLATFORM} in
      OSX )
        brew list thefuck >/dev/null 2>&1 || brew install thefuck
        ;;
      LINUX )
        sudo pip3 install thefuck || exit $?
        ;;
    esac
  elif [ "${COMMAND}" == "update" ]; then
    case ${PLATFORM} in
      OSX )
        brew upgrade thefuck
        ;;
      LINUX )
        sudo pip3 install thefuck --upgrade --force-reinstall || exit $?
        ;;
    esac
  fi

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list thefuck >/dev/null 2>&1 && ++ brew uninstall thefuck
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list thefuck >/dev/null 2>&1 || ++ brew install thefuck
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade thefuck
      fi
      ;;
    LINUX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ sudo pip3 uninstall --yes thefuck
      elif [ "${COMMAND}" == "install" ]; then
        ++ sudo pip3 install thefuck
      elif [ "${COMMAND}" == "update" ]; then
        ++ sudo pip3 install --upgrade --force-reinstall thefuck
      fi
      ;;
  esac
}

version_func_thefuck() {
  $1 --version 2>&1
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_thefuck_local setup_func_thefuck_system version_func_thefuck \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
