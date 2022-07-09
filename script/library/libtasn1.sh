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
  curl --silent --show-error https://ftp.gnu.org/gnu/libtasn1/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.gz\"' | grep -v 'libasn1' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libtasn1-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/libtasn1-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/libtasn1-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/libtasn1-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    curl -LO https://ftp.gnu.org/gnu/libtasn1/libtasn1-${VERSION}.tar.gz || exit $?
    tar -xvzf libtasn1-${VERSION}.tar.gz || exit $?

    mv libtasn1-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/libtasn1-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list libtasn1 || brew install libtasn1 || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade libtasn1 || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libtasn1-6-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install libtasn1-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
