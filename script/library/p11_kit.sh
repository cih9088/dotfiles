#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="p11-glue/p11-kit"

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

  if [ -d ${PREFIX}/src/p11-kit-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/p11-kit-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/p11-kit-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    curl -LO https://github.com/${GH}/releases/download/${VERSION}/p11-kit-${VERSION}.tar.xz || exit $?
    tar -xvJf p11-kit-${VERSION}.tar.xz || exit $?

    mv p11-kit-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/p11-kit-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list p11-kit || brew install p11-kit || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade p11-kit || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install  libp11-kit-dev  || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf install epel-release || exit $?
      sudo dnf -y install p11-kit-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
