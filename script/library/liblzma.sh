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
  curl --silent --show-error https://sourceforge.net/projects/lzmautils/files/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    awk '{print $4}' |
    grep gz | 
    sed -e 's/xz-//' -e 's/.tar.gz//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/xz-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/xz-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/xz-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    wget https://sourceforge.net/projects/lzmautils/files/xz-${VERSION}.tar.gz/download \
      -O xz-${VERSION}.tar.gz || exit $?
    tar -xvzf xz-${VERSION}.tar.gz || exit $?

    mv xz-${VERSION} $HOME/.local/src
    pushd $HOME/.local/src/xz-${VERSION}

    ./configure --prefix=$HOME/.local || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list lzip || brew install lzip || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade lzip || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install  liblzma-dev  || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf install epel-release || exit $?
      sudo dnf -y install liblzma-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
