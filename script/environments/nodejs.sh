#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

has -v asdf gpg

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="node"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

nodejs_install() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=$DEFAULT_VERSION

  # curl -sL install-node.now.sh/lts | bash -s -- --prefix=${HOME}/.local --yes
  # Remove installed node
  rm -rf "$HOME/.local/bin/node" || true
  rm -rf "$HOME/.local/bin/corepack" || true
  rm -rf "$HOME/.local/bin/npm" || true
  rm -rf "$HOME/.local/bin/npx" || true
  rm -rf "$HOME/.local/include/node" || true
  rm -rf "$HOME/.local/lib/node_modules" || true
  rm -rf "$HOME/.local/lib/dtrace" || true
  rm -rf "$HOME/.local/share/doc/node" || true
  rm -rf "$HOME/.local/share/man/man1/node.1" || true
  rm -rf "$HOME/.local/share/systemtap" || true

  if command -v asdf >/dev/null; then
    if [ "${VERSION}" == "latest" ]; then
      VERSION=$(asdf latest nodejs)
    fi

    if [ "${COMMAND}" == "remove" ]; then
      ++ asdf uninstall nodejs "${VERSION}"
    elif [ "${COMMAND}" == "install" ]; then
      ++ asdf install nodejs "${VERSION}"
      ++ asdf global nodejs "${VERSION}"
    elif [ "${COMMAND}" == "update" ]; then
      log_error "Not supported command 'update'"
      exit 0
    fi

  fi
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
