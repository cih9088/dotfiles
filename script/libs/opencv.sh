#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="opencv/opencv"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  ${DIR}/../helpers/gh_list_tags ${GH} |
    grep -v 'openvino')"
DEFAULT_VERSION="$(echo ${AVAILABLE_VERSIONS} | awk '{print $1}')"
################################################################

setup_func_up_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "opencv-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}/build"
      (cat install_manifest.txt; echo) | sh -c 'while read i; do rm $i; done'
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

      ++ curl -LO "https://github.com/${GH}/archive/refs/tags/${VERSION}.tar.gz"
      ++ tar -xvzf "${VERSION}.tar.gz"

      ++ pushd "opencv-${VERSION}"
      ++ mkdir -p build
      ++ pushd build

      ++ cmake .. \
        -D CMAKE_BUILD_TYPE=Release \
        -D OPENCV_GENERATE_PKGCONFIG=YES \
        -D CMAKE_INSTALL_PREFIX=${PREFIX}
      ++ cmake --build . --target install
      ++ popd; ++ popd;

      ++ mv "opencv-${VERSION}" "${PREFIX}/src/"
    fi
  fi
}

setup_func_up_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list opencv >/dev/null 2>&1 && ++ brew uninstall opencv
      elif [ "${COMMAND}" == "install" ]; then
        brew list opencv >/dev/null 2>&1 || ++ brew install opencv
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade opencv
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libopencv-dev python3-opencv
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libopencv-dev python3-opencv
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libopencv-dev python3-opencv
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove opencv-core opencv-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install epel-release
            ++ sudo dnf -y install opencv-core opencv-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update opencv-core opencv-devel
          fi
          ;;
      esac
      ;;
  esac

}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_up_local setup_func_up_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version


