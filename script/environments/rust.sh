#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

has -v asdf

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="rustc"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="latest"
VERSION=""
################################################################

rust_install() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  if command -v asdf > /dev/null; then
    if [ "${VERSION}" == "latest" ]; then
      VERSION=$(asdf latest rust)
    fi

    if [ "${COMMAND}" == "remove" ]; then
      ++ asdf uninstall rust "${VERSION}"
    elif [ "${COMMAND}" == "install" ]; then
      ++ asdf install rust "${VERSION}"
      ++ asdf global rust "${VERSION}"
    elif [ "${COMMAND}" == "update" ]; then
      log_error "Not supported command 'update'"
      exit 0
    fi
  fi
}

rust_version_func() {
  $1 --version | awk '{print $2}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS latest" == *"${1}"* ]]
}

if command -v asdf > /dev/null; then
  asdf plugin list 2>/dev/null | grep -q rust || asdf plugin add rust >&3 2>&4

  log_info "Note that ${THIS_HL} would be installed using asdf"
  AVAILABLE_VERSIONS="$(asdf list all rust)"
  main_script ${THIS} rust_install rust_install rust_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

else
  log_error "asdf not found. Please install it then try again."
  exit 1
fi

