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
  curl --silent --show-error http://ftp.jaist.ac.jp/pub/GNU/libtool/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libtool-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/libtool-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/libtool-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/libtool-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    curl -LOsS http://ftp.jaist.ac.jp/pub/GNU/libtool/libtool-${VERSION}.tar.gz || exit $?
    tar -xvzf libtool-${VERSION}.tar.gz || exit $?

    mv libtool-${VERSION} $HOME/.local/src
    pushd $HOME/.local/src/libtool-${VERSION}

    ./configure --prefix=$HOME/.local || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list libtool || brew install libtool || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade libtool || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libtool || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install libtool || exit $?
    fi
  fi
}

version_func() {
  $1 --version | grep '(GNU' | awk '{print $4}'
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
