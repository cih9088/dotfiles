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
  curl --silent --show-error https://www.boost.org/users/history/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'nofollow' |
    awk '{print $5}' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d $HOME/.local/src/boost_* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd $HOME/.local/src/boost_*
      ./b2 uninstall || true
      popd
      rm -rf $HOME/.local/src/boost_*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    wget https://boostorg.jfrog.io/artifactory/main/release/${VERSION}/source/boost_${VERSION//./_}.tar.gz || exit $?
    tar -xvzf boost_${VERSION//./_}.tar.gz || exit $?

    mv boost_${VERSION//./_} $HOME/.local/src
    pushd  $HOME/.local/src/boost_${VERSION//./_}

    ./bootstrap.sh --prefix=$HOME/.local --with-libraries=all || exit $?
    ./b2 install || exit $?
    # ./b2 install --prefix=$HOME/.local --with=all || exit $?

    popd
  fi

}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list boost || brew install boost || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade boost || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install libboost-all-dev || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install boost-devel || exit $?
    fi
  fi
}

version_func() {
  $1 --version | grep 'gpg' | awk '{print $3}'
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

