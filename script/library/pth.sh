#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

# AVAILABLE_VERSIONS="$(
#   curl --silent --show-error http://www.ossp.org/pkg/lib/pth/ |
#     ${DIR}/../helpers/parser_html 'a' |
#     grep 'tar.gz\"' |
#     awk '{print $5}' |
#     sed -e 's/.tar.gz//' -e 's/pth-//' |
#     sort -Vr)"
# DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
AVAILABLE_VERSIONS=2.0.7
DEFAULT_VERSION=2.0.7
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/pth-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/pth-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/pth-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    # wget ftp://ftp.ossp.org/pkg/lib/pth/pth-${VERSION}.tar.gz || exit $?
    # tar -xvzf pth-${VERSION}.tar.gz || exit $?
    #
    # mv pth-${VERSION} $HOME/.local/src
    # pushd $HOME/.local/src/pth-${VERSION}

    git clone https://github.com/danluu/gnu-pth $HOME/.local/src/pth-${VERSION}
    pushd $HOME/.local/src/pth-${VERSION}

    ./configure --prefix=$HOME/.local \
      --build="$($HOME/.local/share/automake-*/config.guess)" \
      --host="$($HOME/.local/share/automake-*/config.guess)" || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list pth || brew install pth || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade pth || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    log_info "No package in repository. Install it locally."
    setup_func_local ${FORCE}
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
