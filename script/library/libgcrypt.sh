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
  curl --silent --show-error https://gnupg.org/ftp/gcrypt/libgcrypt/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.bz2\"' |
    awk '{print $4}' |
    sed -e 's/.tar.bz2//' -e 's/libgcrypt-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/libgcrypt-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/libgcrypt-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/libgcrypt-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2 || exit $?
    tar -xvjf libgcrypt-${VERSION}.tar.bz2 || exit $?

    mv libgcrypt-${VERSION} $HOME/.local/src
    pushd $HOME/.local/src/libgcrypt-${VERSION}

    ./configure --prefix=$HOME/.local || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list libgcrypt || brew install libgcrypt || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade libgcrypt || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libgcrypt20-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install libgcrypt-devel || exit $?
    fi
  fi
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version