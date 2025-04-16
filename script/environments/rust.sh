#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="rustc"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  if command -v mise > /dev/null; then
    mise ls-remote rust sort -Vr
  elif command -v asdf > /dev/null; then
    asdf plugin list 2>/dev/null | grep -q rust || asdf plugin add rust >&3 2>&4
    asdf list all rust | sort -Vr
  else
    log_error "Install from source is not implemented."
    exit 1
  fi
}

version_func() {
  $1 --version | awk '{print $2}'
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
  elif command -v asdf > /dev/null; then
    log_info "Note that ${THIS_HL} would be handled by asdf."
    from_asdf "$COMMAND" "$VERSION"
  else
    log_error "Install from source is not implemented."
    exit 1
  fi
}

# setup_for_system() {
#   local COMMAND="${1:-skip}"
#
#   case "${PLATFORM}" in
#     OSX)
#       if [ "${COMMAND}" == "remove" ]; then
#         brew list rust >/dev/null 2>&1 && ++ brew uninstall rust
#       elif [ "${COMMAND}" == "install" ]; then
#         brew list rust >/dev/null 2>&1 || ++ brew install rust
#       elif [ "${COMMAND}" == "update" ]; then
#         ++ brew upgrade rust
#       fi
#       ;;
#     LINUX)
#       ;;
#   esac
# }
#
# from_source() {
#   if [ "${COMMAND}" == "remove" ]; then
#   elif [ "${COMMAND}" == "install" ]; then
#     ++ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#   elif [ "${COMMAND}" == "update" ]; then
# }

from_asdf() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="latest"

  asdf plugin list 2>/dev/null | grep -q rust || asdf plugin add rust >&3 2>&4

  if [ "${VERSION}" == "latest" ]; then
    VERSION=$(asdf latest rust)
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ asdf uninstall rust "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ asdf install rust "${VERSION}"
    ++ asdf set -u rust "${VERSION}"
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
    ++ mise unuse -g -y "rust@${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ mise use -g -v "rust@${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi
}

main_script "${THIS}" \
  setup_for_local "" \
  list_versions verify_version version_func
