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
  curl --silent --show-error https://ftp.gnu.org/gnu/readline/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep -v 'doc' | grep -v 'rc' | grep -v 'alph' | grep -v 'beta' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/readline-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/readline-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/readline-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/readline-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://ftp.gnu.org/gnu/readline/readline-${VERSION}.tar.gz || exit $?
    tar -xvzf readline-${VERSION}.tar.gz || exit $?

    mv readline-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/readline-${VERSION}

    ./configure --prefix=${PREFIX} --with-shared || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list readline || brew install readline || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade readline || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libreadline-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install readline-devel || exit $?
    fi
  fi
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
