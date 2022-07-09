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
  curl --silent --show-error https://sourceforge.net/projects/tcl/files/Tcl/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    awk '{print $4}' |
    grep -v '[a-z]' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/tk* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/tk*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/tk*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    curl -L https://sourceforge.net/projects/tcl/files/Tcl/${VERSION}/tk${VERSION}-src.tar.gz/download \
      -o tk${VERSION}-src.tar.gz || exit $?
    tar -xvzf tk${VERSION}-src.tar.gz || exit $?

    mv tk${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/tk${VERSION}

    if [[ ${PLATFORM} == "OSX" ]]; then
      pushd macosx
    elif [[ ${PLATFORM} == "LINUX" ]]; then
      pushd unix
    fi

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd; popd;
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list tcl-tk || brew install tcl-tk || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade tcl-tk || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install  tk-dev  || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install tk-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
