#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="Kitware/CMake"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/cmake-* ]; then
      ++ pushd ${PREFIX}/src/cmake-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/cmake-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d ${PREFIX}/src/cmake-* ]; then

      ++ curl -LO "https://github.com/Kitware/CMake/releases/download/${VERSION}/cmake-${VERSION##v}.tar.gz"
      ++ tar -xvzf "cmake-${VERSION##v}.tar.gz"

      ++ pushd "cmake-${VERSION##v}"
      ++ ./bootstrap --prefix=/root/.local -- -DCMAKE_BUILD_TYPE:STRING=Release
      ++ make
      ++ make install
      ++ popd

      mv "cmake-${VERSION##v}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list cmake >/dev/null 2>&1 && ++ brew uninstall cmake
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list cmake >/dev/null 2>&1 || ++ brew install cmake
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade cmake
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove cmake
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install cmake
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install cmake
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove cmake
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install cmake
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update cmake
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

