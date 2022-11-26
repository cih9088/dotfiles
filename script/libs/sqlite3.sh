#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="3.37.0"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "sqlite-autoconf-*")"

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

      ++ curl -LO https://www.sqlite.org/2021/sqlite-autoconf-3370000.tar.gz
      ++ tar -xvzf sqlite-autoconf-3370000.tar.gz

      ++ pushd sqlite-autoconf-3370000
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv sqlite-autoconf-3370000 "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
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
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libsqlite3-dev libsqlite3-0
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libsqlite3-dev libsqlite3-0
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libsqlite3-dev libsqlite3-0
          fi
          ;;
        RHEL)
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

version_func() {
  $1  --version | awk '{print $1}'
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}"