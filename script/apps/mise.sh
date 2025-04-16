#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="jdx/mise"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
}

version_func() {
  $1 version | tail -n 1
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

  # remove
  if [[ "remove update" == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/mise" ]; then
      rm -rf "${PREFIX}/bin/mise" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update" == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/mise" ]; then
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"
      curl -L "https://mise.run" | MISE_VERSION=${VERSION} MISE_INSTALL_PATH=${PREFIX}/bin/mise sh
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
  OSX)
    if [ "${COMMAND}" == "remove" ]; then
      brew list mise >/dev/null 2>&1 && ++ brew uninstall mise
    elif [ "${COMMAND}" == "install" ]; then
      brew list mise >/dev/null 2>&1 || ++ brew install mise
    elif [ "${COMMAND}" == "update" ]; then
      ++ brew upgrade mise
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
  list_versions verify_version version_func
