#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="libevent/libevent"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -d ${PREFIX}/src/libevent-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/libevent-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/libevent-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    curl -LO https://github.com/libevent/libevent/releases/download/${VERSION}/${VERSION/release/libevent}.tar.gz || exit $?
    tar -xvzf ${VERSION/release/libevent}.tar.gz || exit $?

    mv ${VERSION/release/libevent} ${PREFIX}/src
    pushd ${PREFIX}/src/${VERSION/release/libevent}

    ./configure --prefix=${PREFIX} --enable-shared || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list libevent || brew install libevent || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade libevent || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install libevent-dev || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      sudo dnf -y install libevent-devel || exit $?
    fi
  fi
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
