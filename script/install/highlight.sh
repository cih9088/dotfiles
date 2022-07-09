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
  curl --silent --show-error http://mirror.rit.edu/gnu/src-highlite/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/source-highlight-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/source-highlight-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/source-highlight-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/source-highlight-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    curl -LO http://mirror.rit.edu/gnu/src-highlite/source-highlight-${VERSION}.tar.gz || exit $?
    tar -xvzf source-highlight-${VERSION}.tar.gz || exit $?

    mv source-highlight-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/source-highlight-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list highlight || brew install highlight || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade highlight || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install highlight || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install highlight || exit $?
    fi
  fi
}

version_func() {
  $1 --version | grep 'gpg' | awk '{print $3}'
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

