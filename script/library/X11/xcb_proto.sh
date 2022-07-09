#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://www.x.org/archive/individual/proto/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'xcb-proto' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/xcb-proto-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/xcb-proto-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/xcb-proto-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/xcb-proto-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    curl -LO https://www.x.org/archive/individual/proto/xcb-proto-${VERSION}.tar.gz || exit $?
    tar -xvzf xcb-proto-${VERSION}.tar.gz || exit $?

    mv xcb-proto-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/xcb-proto-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list xcb-proto || brew install xcb-proto || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade xcb-proto || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install xcb-proto || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install libxcb || exit $?
    fi
  fi
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
