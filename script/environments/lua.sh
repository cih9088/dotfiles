#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${CUR_DIR}/../helpers/common.sh"
################################################################

has -v asdf

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  if command -v asdf > /dev/null; then
    asdf plugin list 2>/dev/null | grep -q lua || asdf plugin add lua >&3 2>&4
    asdf list all lua | sort -Vr
  fi
}

version_func() {
  $1 -v | awk '{print $2}'
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
  [ -z "${VERSION}" ] && VERSION=latest

  if command -v asdf > /dev/null; then
    log_info "Note that ${THIS_HL} would be installed using asdf."
    from_asdf "$COMMAND" "$VERSION"
  else
    log_error "Install from source is not implemented."
    exit 1
  fi
}

from_asdf() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  asdf plugin list 2>/dev/null | grep -q lua || asdf plugin add lua >&3 2>&4

  if [ "${VERSION}" == "latest" ]; then
    VERSION=$(asdf latest lua)
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ asdf uninstall lua "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ ASDF_LUA_LINUX_READLINE=1 asdf install lua "${VERSION}"
    ++ asdf global lua "${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi
}

main_script "${THIS}" \
  setup_for_local "" \
  list_versions verify_version version_func
