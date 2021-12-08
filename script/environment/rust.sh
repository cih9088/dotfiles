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
################################################################

rust_install() {
  local VERSION="${2:-}"

  if command -v asdf > /dev/null; then
    asdf install rust ${VERSION}
  fi
}

rust_version_func() {
  $1 --version | awk '{print $2}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS latest" == *"${1}"* ]]
}

if command -v asdf > /dev/null; then
  asdf plugin list | grep -q rust || asdf plugin add rust >&3 2>&4

  log_info "Note that ${THIS_HL} would be installed using asdf"
  AVAILABLE_VERSIONS="$(asdf list all rust)"
  main_script ${THIS} rust_install rust_install rust_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

  # exit immediately with no reaason
  # asdf current rust >/dev/null 2>&1 || asdf global rust \
  cat $HOME/.tool-versions 2>/dev/null | grep -q rust || asdf global rust \
    $(asdf list rust | sed 's/[[:space:]]//g' | sort -V -r | head -n 1)
else
  log_error "asdf not found. Install it by 'make installAsdf' before this."
  exit 1
fi

