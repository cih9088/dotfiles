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

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "libsodium-*")"

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

      ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/libsodium-${VERSION/-RELEASE/}.tar.gz"
      ++ tar -xvzf "libsodium-${VERSION/-RELEASE/}.tar.gz"

      ++ pushd "libsodium-${VERSION/-RELEASE/}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      mv libsodium-${VERSION/-RELEASE/} $HOME/.local/src
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list libsodium >/dev/null 2>&1 && ++ brew uninstall libsodium
      elif [ "${COMMAND}" == "install" ]; then
        brew list libsodium >/dev/null 2>&1 || ++ brew install libsodium
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libsodium
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libsodium-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libsodium-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libsodium-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libsodium-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install epel-release
            ++ sudo dnf -y install libsodium-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libsodium-devel
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
