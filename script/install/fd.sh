#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="sharkdp/fd"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -f ${HOME}/.local/bin/fd ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf $HOME/.local/bin/fd || true
      rm -rf $HOME/.local/man/man1/fd.1 || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    if [[ ${PLATFORM} == "OSX" ]]; then
      # does not have aarch64 for apple
      wget https://github.com/${GH}/releases/download/${VERSION}/fd-${VERSION}-x86_64-apple-darwin.tar.gz || exit $?
      tar -xvzf fd-${VERSION}-x86_64-apple-darwin.tar.gz || exit $?

      pushd fd-${VERSION}-x86_64-apple-darwin
      yes | \cp -rf fd $HOME/.local/bin
      yes | \cp -rf fd.1 $HOME/.local/man/man1
      popd

    elif [[ ${PLATFORM} == "LINUX" ]]; then
      wget https://github.com/${GH}/releases/download/${VERSION}/fd-${VERSION}-${ARCH}-unknown-linux-gnu.tar.gz || eixt $?
      tar -xvzf fd-${VERSION}-${ARCH}-unknown-linux-gnu.tar.gz || exit $?

      pushd fd-${VERSION}-${ARCH}-unknown-linux-gnu
      yes | \cp -rf fd $HOME/.local/bin
      yes | \cp -rf fd.1 $HOME/.local/man/man1
      popd

    fi
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list fd || brew install fd || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade fd || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get install -y fd-find || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      # sudo dnf install -y fd-find || exit $?
      log_info "No package in repository. Install it locally."
      setup_func_local ${FORCE}
    fi
  fi
}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
