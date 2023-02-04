#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

has -v asdf

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

nodejs_install() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=$DEFAULT_VERSION

  if [ "${COMMAND}" == "remove" ]; then
    ++ npm uninstall --global prettier
    ++ npm uninstall --global yarn
    ++ npm uninstall --global typescript
  elif [ "${COMMAND}" == "install" ]; then
    ++ npm install --global prettier
    ++ npm install --global yarn
    ++ npm install --global typescript
  elif [ "${COMMAND}" == "update" ]; then
    ++ npm update --global prettier
    ++ npm update --global yarn
    ++ npm update --global typescript
  fi
  ++ asdf reshim
}

nodejs_version_func() {
  $1 --version
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS latest" == *"${1}"* ]]
}

if command -v asdf >/dev/null; then
  asdf plugin list 2>/dev/null | grep -q nodejs || asdf plugin add nodejs >&3 2>&4

  log_info "Note that ${THIS_HL} would be installed using asdf"
  AVAILABLE_VERSIONS="$(asdf list all nodejs)"
  main_script "${THIS}" nodejs_install nodejs_install nodejs_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

else
  log_error "asdf not found. Please install it then try again."
  exit 1
fi

