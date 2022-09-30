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
  curl --silent --show-error https://gmplib.org/download/gmp/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.xz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.xz//' -e 's/gmp-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/gmp-* ]; then
      ++ pushd ${PREFIX}/src/gmp-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/gmp-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/gmp-* ]; then

      ++ curl -LO "https://gmplib.org/download/gmp/gmp-${VERSION}.tar.xz"
      ++ tar -xvJf "gmp-${VERSION}.tar.xz"

      ++ pushd "gmp-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make check
      ++ make install
      ++ popd

      ++ mv "gmp-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list nettle >/dev/null 2>&1 && ++ brew uninstall nettle
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list nettle >/dev/null 2>&1 || ++ brew install nettle
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade nettle
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove nettle-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install nettle-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install nettle-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove nettle-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install nettle-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update nettle-devel
          fi
          ;;
      esac
      ;;
  esac

}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
