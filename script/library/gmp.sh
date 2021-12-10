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
  curl --silent --show-error https://gmplib.org/download/gmp/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.xz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.xz//' -e 's/gmp-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/gmp-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/gmp-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/gmp-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://gmplib.org/download/gmp/gmp-${VERSION}.tar.xz || exit $?
    tar -xvJf gmp-${VERSION}.tar.xz || exit $?

    mv gmp-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/gmp-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list nettle || brew install nettle || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade nettle || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install nettle-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install nettle-devel || exit $?
    fi
  fi
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version