#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

has -v gpg

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="node"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  if command -v mise > /dev/null; then
    echo "latest"
    mise ls-remote nodejs | grep -v '[a-zA-Z]' | sort -Vr
  elif command -v asdf > /dev/null; then
    asdf plugin list 2>/dev/null | grep -q nodejs || asdf plugin add nodejs >&3 2>&4
    asdf list all nodejs | sort -Vr
  else
    echo lts
    curl --silent https://nodejs.org/download/release/ |
      ${DIR}/../helpers/parser_html 'a' |
      awk '{print $NF}' |
      grep '^v' | sed 's|/||' |
      sort -Vr
  fi
}

version_func() {
  $1 --version
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

  if command -v mise > /dev/null; then
    log_info "Note that ${THIS_HL} would be handled by mise."
    from_mise "$COMMAND" "$VERSION"
  elif command -v asdf >/dev/null; then
    log_info "Note that ${THIS_HL} would be handled by asdf."
    from_asdf "$COMMAND" "$VERSION"
  else
    log_info "Note that ${THIS_HL} would be handled by source."
    from_source "$COMMAND" "$VERSION"
  fi
}

from_source() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

  # remove
  if [[ "remove"  == *"${COMMAND}"* ]]; then
    rm -rf "$PREFIX/bin/node" || true
    rm -rf "$PREFIX/bin/npm" || true
    rm -rf "$PREFIX/bin/npx" || true
    rm -rf "$PREFIX/bin/corepack" || true
    rm -rf "$PREFIX/include/node" || true
    rm -rf "$PREFIX/lib/node_modules" || true
    rm -rf "$PREFIX/share/doc/node" || true
    rm -rf "$PREFIX/share/man/man1/node.1" || true
    rm -rf "$PREFIX/share/systemtap/tapset/node.stp" || true
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    curl -sL install-node.now.sh/${VERSION} | bash -s -- --prefix=${PREFIX} --yes
  fi
}

from_asdf() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=latest

  asdf plugin list 2>/dev/null | grep -q nodejs || asdf plugin add nodejs >&3 2>&4

  if [ "${VERSION}" == "latest" ]; then
    VERSION=$(asdf latest nodejs)
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ asdf uninstall nodejs "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ asdf install nodejs "${VERSION}"
    ++ asdf set -u nodejs "${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi
}

from_mise() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=latest

  if [ "${COMMAND}" == "remove" ]; then
    ++ mise unuse -g -y "nodejs@${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ mise use -g -v "nodejs@${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi
}

main_script "${THIS}" \
  setup_for_local "" \
  list_versions verify_version version_func
