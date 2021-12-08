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
  curl --silent --show-error https://ftp.gnu.org/pub/gnu/ncurses/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'ncurses' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/ncurses-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE=$1
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/ncurses-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/ncurses-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/ncurses-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${VERSION}.tar.gz || exit $?
    tar -xvzf ncurses-${VERSION}.tar.gz || exit $?

    mv ncurses-${VERSION} $HOME/.local/src
    pushd $HOME/.local/src/ncurses-${VERSION}

    # ./configure --prefix=$HOME/.local --with-shared --without-debug --enable-widec
    # ./configure --prefix=$HOME/.local --with-shared --with-termlib --enable-pc-files || exit $?
    ./configure --prefix=$HOME/.local --with-shared --enable-pc-files || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list ncurses || brew install ncurses || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade ncurses || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libncurses5-dev libncursesw5-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install ncurses-devel || exit $?
    fi
  fi
}

version_func() {
  $1 --version
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
