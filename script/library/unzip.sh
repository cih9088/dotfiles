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
  curl --silent --show-error https://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    awk '{print $5}' |
    grep -v '[a-z]' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/unzip* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/unzip*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/unzip*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    curl -L https://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/UnZip%20${VERSION}/unzip${VERSION/./}.tar.gz/download \
      -o unzip${VERSION/./}.tar.gz || exit $?
    tar -xvzf unzip${VERSION/./}.tar.gz || exit $?

    mv unzip${VERSION/./} ${PREFIX}/src
    pushd ${PREFIX}/src/unzip${VERSION/./}

    make -f unix/Makefile generic || exit $?
    make prefix=${PREFIX} MANDIR=${PREFIX}/share/man/man1 -f unix/Makefile install || exit $?

    popd;
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list unzip || brew install unzip || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade unzip || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install  unzip  || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install unzip || exit $?
    fi
  fi
}

version_func() {
  $1 -h | head -1 | cut -d ',' -f1
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

