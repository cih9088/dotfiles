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
  curl --silent --show-error http://ftp.gnu.org/gnu/groff/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/groff-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/groff-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/groff-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/groff-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://ftp.gnu.org/gnu/groff/groff-${VERSION}.tar.gz || exit $?
    tar -xvzf groff-${VERSION}.tar.gz || exit $?

    mv groff-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/groff-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list groff || brew install groff || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade groff || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install groff || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      sudo dnf install -y dnf-plugins-core || exit $?
      sudo dnf config-manager --set-enabled powertools || exit $?
      sudo dnf -y install groff || exit $?
    fi
  fi
}

version_func() {
  $1 -v | head -n 1 | awk '{print $4}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
