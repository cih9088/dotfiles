#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="rustc"

log_title "Prepare environment for ${THIS_HL}"

DEFAULT_VERSION="latest"
VERSION=""
################################################################

rust_install() {
  VERSION="${2:-}"

  if command -v asdf > /dev/null; then
    if [ ${VERSION} == "latest" ]; then
      VERSION=$(asdf latest rust)
    fi
    asdf install rust ${VERSION}
    asdf global rust ${VERSION}
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
  log_error "asdf not found. Install it by 'make installAsdf' before this."
  exit 1
fi

