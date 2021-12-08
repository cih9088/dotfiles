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
  curl --silent --show-error https://www.sourceware.org/pub/bzip2/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep -v 'bzip-' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/bzip2-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/bzip2-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/bzip2-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/bzip2-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://www.sourceware.org/pub/bzip2/bzip2-${VERSION}.tar.gz || exit $?
    tar -xvzf bzip2-${VERSION}.tar.gz || eixt $?

    mv bzip2-${VERSION} $HOME/.local/src
    pushd $HOME/.local/src/bzip2-${VERSION}

    make install PREFIX=$HOME/.local || exit $?

    # Build shared library
    make clean
    make -f Makefile-libbz2_so
    mv bzip2-shared $HOME/.local/bin
    mv libbz2.so* $HOME/.local/lib

    # link libbz2.so forcefully
    pushd $HOME/.local/lib
    ln -snf libbz2.so.${VERSION} libbz2.so

    popd; popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list bzip2 || brew install bzip2 || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade bzip2 || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libbz2-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install bzip2-devel || exit $?
    fi
  fi
}

version_func() {
  $1 --help 2>&1 | grep Version | awk '{for(i=7;i<=NF;++i) printf $i " "; printf "\n"}'
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version