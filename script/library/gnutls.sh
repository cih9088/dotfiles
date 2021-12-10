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
  curl --silent --show-error https://www.gnupg.org/ftp/gcrypt/gnutls/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep '\"v' |
    awk '{print $4}' |
    sort -Vr | sed '1d')" # latest version is not stable release but next release
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/gnutls-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/gnutls-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/gnutls-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then

    _FINAL_VERSION="$(curl --silent --show-error https://www.gnupg.org/ftp/gcrypt/gnutls/${VERSION}/ |
      ${DIR}/../helpers/parser_html 'a' |
      grep 'tar.xz\"' |
      awk '{print $4}' |
      sed -e 's/.tar.xz//' -e 's/gnutls-//' |
      sort -Vr | head -n 1)"

    wget https://www.gnupg.org/ftp/gcrypt/gnutls/${VERSION}/gnutls-${_FINAL_VERSION}.tar.xz || exit $?
    tar -xvJf gnutls-${_FINAL_VERSION}.tar.xz || exit $?

    mv gnutls-${_FINAL_VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/gnutls-${_FINAL_VERSION}

    ./configure --prefix=${PREFIX} --with-included-unistring
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list gnutls || brew install gnutls || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade gnutls || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install gnutls-bin || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install gnutls-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
