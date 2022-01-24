#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="mvdan/sh"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=shfmt

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_shfmt_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z "$VERSION" ] && VERSION="$DEFAULT_VERSION"

  if [ -f "${PREFIX}/bin/shfmt" ]; then
    if [ "${FORCE}" == "true" ]; then
      rm -rf "${PREFIX}/bin/shfmt" || true
      DO_INSTALL='true'
    fi
  else
    DO_INSTALL='true'
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    if [ "${ARCH}" == "x86_64" ]; then
      _ARCH=amd64
    elif [ "${ARCH}" == "aarch64" ]; then
      _ARCH=arm64
    fi

    if [[ ${PLATFORM} == "OSX" ]]; then
      # does not have aarch64 for apple
      wget https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_darwin_${_ARCH} || exit $?
      chmod +x shfmt_${VERSION}_darwin_${_ARCH}
      \cp -rf shfmt_${VERSION}_darwin_${_ARCH} ${PREFIX}/bin/shfmt
    elif [[ ${PLATFORM} == "LINUX" ]]; then
      wget https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_linux_${_ARCH} || exit $?
      chmod +x shfmt_${VERSION}_linux_${_ARCH}
      \cp -rf shfmt_${VERSION}_linux_${_ARCH} ${PREFIX}/bin/shfmt
    fi
  fi
}

setup_func_shfmt_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list shfmt || brew install shfmt || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade shfmt || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    log_info "No package in repository. Install it locally."
    setup_func_shfmt_local ${FORCE}
  fi
}

version_func_shfmt() {
  $1 -version
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_shfmt_local setup_func_shfmt_system version_func_shfmt \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

