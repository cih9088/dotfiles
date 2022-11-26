#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="openssl/openssl"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  ./script/helpers/gh_list_tags ${GH} |
    grep -o 'openssl-[0-9.]\+' | 
    sed -e 's/openssl-//' |
    uniq | 
    sort -Vr
)"
DEFAULT_VERSION=$(echo "${AVAILABLE_VERSIONS}" | head -1)
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "openssl-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}"
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf "${SRC_PATH}"
      SRC_PATH=""
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ -z "${SRC_PATH}" ]; then

      ++ curl -LO "https://github.com/openssl/openssl/archive/refs/tags/openssl-${VERSION}.tar.gz"
      ++ tar -xvzf "openssl-${VERSION}.tar.gz"

      ++ pushd "openssl-openssl-${VERSION}"
      ++ ./Configure --prefix="${PREFIX}" shared zlib
      ++ make
      ++ make install
      ++ popd

      ++ mv "openssl-openssl-${VERSION}" "${PREFIX}/src/openssl-${VERSION}"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list openssl >/dev/null 2>&1 && ++ brew uninstall openssl
      elif [ "${COMMAND}" == "install" ]; then
        brew list openssl >/dev/null 2>&1 || ++ brew install openssl
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade openssl
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove openssl libssl-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install openssl libssl-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install openssl libssl-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove openssl-devel openssl
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install openssl-devel openssl
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update openssl-devel openssl
          fi
          ;;
      esac
      ;;
  esac

}

version_func() {
  $1 version | awk '{print $2}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version