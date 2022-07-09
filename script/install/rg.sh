#!/usr/bin/env bash
# Original repo of ripgrep is https://github.com/BurntSushi/ripgrep
# but it has limited number of pre-built binaries.
# This script will download pre-built binary from microsoft.

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="microsoft/ripgrep-prebuilt"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_rg_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -f ${PREFIX}/bin/rg ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf ${PREFIX}/bin/rg || true
      rm -rf ${PREFIX}/man/man1/rg.1 || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    if [[ ${PLATFORM} == "OSX" ]]; then
      curl -LO https://github.com/microsoft/ripgrep-prebuilt/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz || exit $?
      tar -xvzf ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz || exit $?
      \cp -rf rg ${PREFIX}/bin
    elif [[ ${PLATFORM} == "LINUX" ]]; then
      curl -LO https://github.com/microsoft/ripgrep-prebuilt/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz || exit $?
      tar -xvzf ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz || exit $?
      \cp -rf rg ${PREFIX}/bin
    fi
  fi
}

setup_func_rg_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list ripgrep || brew install ripgrep || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade ripgrep || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install ripgrep || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      log_info "No package in repository. Install it locally."
      setup_func_rg_local ${FORCE}
    fi
  fi
}

version_func_rg() {
  $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_rg_local setup_func_rg_system version_func_rg \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
