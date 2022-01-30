#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

VERSION=3.0.0
################################################################

setup_func_local() {
  local FORCE=$1

  local DO_INSTALL=no
  if [ -d ${PREFIX}/src/openssl-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/openssl-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/openssl-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://github.com/openssl/openssl/archive/refs/tags/openssl-${VERSION}.tar.gz || exit $?
    tar -xvzf openssl-${VERSION}.tar.gz || exit $?

    mv openssl-openssl-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/openssl-openssl-${VERSION}

    ./Configure --prefix=${PREFIX} shared zlib || exit $?
    make || exit $?
    make install || exit $?


    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list openssl || brew install openssl || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade openssl || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install openssl libssl-dev || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      sudo dnf -y install openssl openssl-devel || exit $?
    fi
  fi
}

version_func() {
  $1 version | awk '{print $2}'
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "$VERSION"
