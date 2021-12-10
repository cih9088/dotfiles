#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="libffi/libffi"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH} | grep -v 'rc')"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/libffi-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/libffi-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/libffi-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://github.com/${GH}/releases/download/${VERSION}/libffi-${VERSION##v}.tar.gz || exit $?
    tar -xvzf libffi-${VERSION##v}.tar.gz || exit $?

    mv libffi-${VERSION##v} ${PREFIX}/src
    pushd ${PREFIX}/src/libffi-${VERSION##v}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list libffi || brew install libffi || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade libffi || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install  libffi-dev  || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install libffi-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
