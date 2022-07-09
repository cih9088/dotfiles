#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/gnu/gzip/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/gzip-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/gzip-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/gzip-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/gzip-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    curl -LO https://ftp.gnu.org/gnu/gzip/gzip-${VERSION}.tar.gz || exit $?
    tar -xvzf gzip-${VERSION}.tar.gz || exit $?

    mv gzip-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/gzip-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list gzip || brew install gzip || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade gzip || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install gzip || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install gzip || exit $?
    fi
  fi
}

version_func() {
  $1 --version | grep '^GNU' | awk '{print $3}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

