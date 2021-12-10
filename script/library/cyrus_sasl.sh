#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="cyrusimap/cyrus-sasl"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/cyrus-sasl-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/cyrus-sasl-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/cyrus-sasl-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    wget https://github.com/${GH}/releases/download/${VERSION}/${VERSION}.tar.gz || exit $?
    tar -xvzf ${VERSION}.tar.gz || exit $?

    mv ${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list cyrus-sasl || brew install cyrus-sasl || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade cyrus-sasl || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install  libsasl2-dev  || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install cyrus-sasl-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
