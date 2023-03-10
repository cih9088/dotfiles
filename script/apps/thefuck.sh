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
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
}

version_func_thefuck() {
  $1 --version 2>&1
}

verify_version() {
  local TARGET_VERSION="${1}"
  local AVAILABLE_VERSIONS="${2}"
  AVAILABLE_VERSIONS=$(echo "${AVAILABLE_VERSIONS}" | tr "\n\r" " ")
  [[ " ${AVAILABLE_VERSIONS} " == *" ${TARGET_VERSION} "* ]]
}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="$(list_versions | head -n 1)"

  if [ "${COMMAND}" == "remove" ]; then
    intelli_pip3 uninstall --yes thefuck || exit $?
  elif [ "${COMMAND}" == "install" ]; then
    intelli_pip3 install thefuck=="${VERSION}" || exit $?
  elif [ "${COMMAND}" == "update" ]; then
    intelli_pip3 install --force-reinstall --upgrade thefuck=="${VERSION}" || exit $?
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list thefuck >/dev/null 2>&1 && ++ brew uninstall thefuck
      elif [ "${COMMAND}" == "install" ]; then
        brew list thefuck >/dev/null 2>&1 || ++ brew install thefuck
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

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
