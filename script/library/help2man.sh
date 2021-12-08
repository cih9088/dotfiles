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
  curl --silent --show-error https://gnuftp.uib.no/help2man/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/help2man-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/help2man-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/help2man-*
      make uninstall || true
      make clean || true
      popd
      rm -rf $HOME/.local/src/help2man-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    wget https://gnuftp.uib.no/help2man/help2man-${VERSION}.tar.gz || exit $?
    tar -xvzf help2man-${VERSION}.tar.gz || exit $?

    mv help2man-${VERSION} $HOME/.local/src
    pushd $HOME/.local/src/help2man-${VERSION}

    ./configure --prefix=$HOME/.local || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list help2man || brew install help2man || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade help2man || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install help2man || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf install -y dnf-plugins-core || exit $?
      sudo dnf config-manager --set-enabled powertools || exit $?
      sudo dnf -y install help2man || exit $?
    fi
  fi
}

version_func() {
  $1 --version | grep 'GNU' | awk '{print $3}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
