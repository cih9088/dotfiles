#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare environment for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

lua_install() {
  local VERSION="${2:-}"

  if command -v asdf > /dev/null; then
    if [ ${VERSION} == "latest" ]; then
      VERSION=$(asdf latest lua)
    fi
    asdf install lua ${VERSION}
    asdf global lua ${VERSION}

    # install utils
    luarocks install --server=https://luarocks.org/dev luaformatter
    asdf reshim
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
  main_script ${THIS} lua_install lua_install lua_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

else
  log_error "asdf not found. Install it by 'make installAsdf' before this."
  exit 1
fi

