#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="sqlite/sqlite"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_tags" "${GH}")" | grep '[0-9]'
}

version_func() {
  $1  --version | awk '{print $1}'
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
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "sqlite-autoconf-*")"

  # removehttps://github.com/sqlite/sqlite/archive/refs/tags/version-3.41.0.tar.gz
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}"
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf "$PREFIX/bin/sqlite3" || true
      rm -rf "$PREFIX/include/sqlite3.h" || true
      rm -rf "$PREFIX/include/sqlite3ext.h" || true
      rm -rf "$PREFIX/lib/libsqlite3*" || true
      rm -rf "$PREFIX/lib/pkgconfig/sqlite3.pc" || true
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

      ++ curl -L "https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=${VERSION}" -o sqlite-${VERSION}.tar.gz
      ++ tar -xvzf "sqlite-${VERSION}.tar.gz"

      ++ pushd "sqlite"
      ++ mkdir build && ++ cd build
      ++ ../configure --prefix="${PREFIX}"
      ++ make
      ++ make sqlite3.c
      ++ make install
      ++ popd

      ++ mv "sqlite" "${PREFIX}/src/sqlite-${VERSION}"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list sqlite3 >/dev/null 2>&1 && ++ brew uninstall sqlite3
      elif [ "${COMMAND}" == "install" ]; then
        brew list sqlite3 >/dev/null 2>&1 || ++ brew install sqlite3
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade sqlite3
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libsqlite3-dev libsqlite3-0
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libsqlite3-dev libsqlite3-0
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libsqlite3-dev libsqlite3-0
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove sqlite-devel sqlite
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install sqlite-devel sqlite
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update sqlite-devel sqlite
          fi
          ;;
      esac
      ;;
  esac
}
main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
