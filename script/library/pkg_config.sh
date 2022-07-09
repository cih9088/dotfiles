#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD="pkg-config"

log_title "Prepare to install ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://pkgconfig.freedesktop.org/releases/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'pkg-config' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/pkg-config-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/pkg-config-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/pkg-config-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/pkg-config-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    curl -LO https://pkgconfig.freedesktop.org/releases/pkg-config-${VERSION}.tar.gz || exit $?
    tar -xvzf pkg-config-${VERSION}.tar.gz || exit $?

    mv pkg-config-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/pkg-config-${VERSION}

    ./configure --prefix=${PREFIX} --enable-shared --enable-static --with-internal-glib || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list pkg-config || brew install pkg-config || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade pkg-config || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install pkg-config || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install pkg-config || exit $?
    fi
  fi
}

version_func() {
  $1 --version
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
