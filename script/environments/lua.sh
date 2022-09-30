#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${CUR_DIR}/../helpers/common.sh"
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

lua_install() {
  local VERSION="${2:-}"

  if command -v asdf > /dev/null; then
    if [ "${VERSION}" == "latest" ]; then
      VERSION=$(asdf latest lua)
    fi
    asdf install lua "${VERSION}"
    asdf global lua "${VERSION}"
  fi

}

lua_version_func() {
  $1 -v | awk '{print $2}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS latest" == *"${1}"* ]]
}

if command -v asdf > /dev/null; then
  asdf plugin list 2>/dev/null | grep -q lua || asdf plugin add lua >&3 2>&4

  log_info "Note that ${THIS_HL} would be installed using asdf"
  AVAILABLE_VERSIONS="$(asdf list all lua)"
  main_script "${THIS}" lua_install lua_install lua_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

else
  log_error "asdf not found. Please install it then try again."
  exit 1
fi
