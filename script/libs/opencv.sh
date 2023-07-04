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
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")" |
    grep -v 'rc' |
    grep -v 'beta' |
    grep -v 'alpha'
}

verify_version() {
  local TARGET_VERSION="${1}"
  local AVAILABLE_VERSIONS="${2}"
  AVAILABLE_VERSIONS=$(echo "${AVAILABLE_VERSIONS}" | tr "\n\r" " ")
  [[ " ${AVAILABLE_VERSIONS} " == *" ${TARGET_VERSION} "* ]]
}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
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
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

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

setup_for_system() {
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
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libopencv-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libopencv-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libopencv-dev
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove opencv-core opencv-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install epel-release
            local crb_name="crb"
            if [ "$(echo "${PLATFORM_VERSION}" | awk -F . '{print $1}')" -lt 9 ]; then
              crb_name="powertools"
            fi
            ++ sudo dnf -y --enablerepo=$crb_name install opencv-devel opencv-core
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update opencv-core opencv-devel
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
