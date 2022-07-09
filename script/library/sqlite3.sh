#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="3.37.0"
################################################################

setup_func_local() {
  local FORCE="$1"
  local DO_INSTALL=no

  if [ -d ${PREFIX}/src/sqlite-autoconf-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/sqlite-autoconf-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/sqlite-autoconf-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    curl -LO https://www.sqlite.org/2021/sqlite-autoconf-3370000.tar.gz || exit $?
    tar -xvzf sqlite-autoconf-3370000.tar.gz || exit $?

    mv sqlite-autoconf-3370000 ${PREFIX}/src
    pushd ${PREFIX}/src/sqlite-autoconf-3370000

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list sqlite3 || brew install sqlite3 || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade sqlite || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libsqlite3-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install sqlite-devel || exit $?
    fi
  fi
}

version_func() {
  $1  --version | awk '{print $1}'
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}"
