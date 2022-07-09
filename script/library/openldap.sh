#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="jedisct1/libsodium"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://www.openldap.org/software/download/OpenLDAP/openldap-release/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tgz\"' | grep -v 'snacc-' |
    awk '{print $4}' |
    sed -e 's/.tgz//' -e 's/openldap-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local FORCE="$1"
  local VERSION="${2:-}"
  local DO_INSTALL=no

  [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

  if [ -d ${PREFIX}/src/openldap-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/openldap-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/openldap-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    curl -LO https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${VERSION}.tgz || exit $?
    tar -xvzf openldap-${VERSION}.tgz || exit $?

    mv openldap-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/openldap-${VERSION}

    ./configure --prefix=${PREFIX} --enable-slapd=no || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list openldap || brew install openldap || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade openldap || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ ${FAMILY} == "DEBIAN" ]]; then
      sudo apt-get -y install  libldap2-dev  || exit $?
    elif [[ ${FAMILY} == "RHEL" ]]; then
      sudo dnf -y install openldap-devel || exit $?
    fi
  fi
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
