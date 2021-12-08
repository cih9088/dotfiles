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
  curl --silent --show-error https://ftp.gnu.org/gnu/autoconf/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/autoconf-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/autoconf-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/autoconf-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/autoconf-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://ftp.gnu.org/gnu/autoconf/autoconf-${VERSION}.tar.gz || exit $?
    tar -xvzf autoconf-${VERSION}.tar.gz || exit $?

    mv autoconf-${VERSION} $HOME/.local/src
    pushd $HOME/.local/src/autoconf-${VERSION}

    ./configure --prefix=$HOME/.local || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list autoconf || brew install autoconf || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade autoconf || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install autoconf || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install autoconf || exit $?
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
