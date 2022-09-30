#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/gnu/autoconf/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/autoconf-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d "${PREFIX}"/src/autoconf-* ]; then
      ++ pushd "${PREFIX}"/src/autoconf-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf "${PREFIX}"/src/autoconf-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi
  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/autoconf-* ]; then

      ++ curl -LO "https://ftp.gnu.org/gnu/autoconf/autoconf-${VERSION}.tar.gz"
      ++ tar -xvzf "autoconf-${VERSION}.tar.gz"

      ++ pushd "autoconf-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "autoconf-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list autoconf >/dev/null 2>&1 && ++ brew uninstall autoconf
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list autoconf >/dev/null 2>&1 || ++ brew install autoconf
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade autoconf
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove autoconf
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install autoconf
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install autoconf
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove autoconf
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install autoconf
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update autoconf
          fi
          ;;
      esac
      ;;
  esac

}

version_func() {
  $1 --version | grep '(GNU' | awk '{print $4}'
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
