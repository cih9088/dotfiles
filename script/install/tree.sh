#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION=1.8.0
################################################################


setup_func_tree_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -d ${PREFIX}/src/tree-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/tree-*
      make clean || true
      popd
      rm -rf ${PREFIX}/src/tree-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    curl -LO http://mama.indstate.edu/users/ice/tree/src/tree-${VERSION}.tgz || exit $?
    tar -xvzf tree-${VERSION}.tgz || exit $?

    mv tree-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/tree-${VERSION}

    sed -i -e "s|prefix = /usr|prefix = ${PREFIX}|" Makefile || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_tree_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list tree || brew install tree || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade tree || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install tree || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      sudo dnf -y install tree || exit $?
    fi
  fi
}

version_func_tree() {
  $1 --version | awk '{print $2}'
}

main_script ${THIS} setup_func_tree_local setup_func_tree_system version_func_tree \
  "${DEFAULT_VERSION}"
