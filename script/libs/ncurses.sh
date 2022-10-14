#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/pub/gnu/ncurses/ \
    | ${DIR}/../helpers/parser_html 'a' \
    | grep 'ncurses' | grep 'tar.gz\"' \
    | awk '{print $4}' \
    | sed -e 's/.tar.gz//' -e 's/ncurses-//' \
    | sort -Vr
)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1)
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  local SRC_PATH_2=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "ncurses-*")"
  SRC_PATH_2="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "ncursesw-*")"

  # remove
  if [[ "remove update" == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ] || [ -n "${SRC_PATH_2}" ] ; then
      if [ -n "${SRC_PATH}" ]; then
        ++ pushd "${SRC_PATH}"
        make uninstall || true
        make clean || true
        ++ popd
        rm -rf "${SRC_PATH}"
        SRC_PATH=""
      fi

      if [ -n "${SRC_PATH_2}" ]; then
        ++ pushd "${SRC_PATH_2}"
        make uninstall || true
        make clean || true
        ++ popd
        rm -rf "${SRC_PATH_2}"
        SRC_PATH_2=""
      fi
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update" == *"${COMMAND}"* ]]; then
    if [ -z "${SRC_PATH}" ] || [ -z "${SRC_PATH_2}" ] ; then
      ++ curl -LO "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${VERSION}.tar.gz"

      if [ -z "${SRC_PATH}" ]; then
        ++ tar -xvzf "ncurses-${VERSION}.tar.gz"

        ++ pushd "ncurses-${VERSION}"
        ++ ./configure \
          --prefix="${PREFIX}" \
          --with-normal \
          --with-shared \
          --enable-pc-files \
          --with-versioned-syms
        ++ make
        ++ make install.includes
        ++ make install.libs
        ++ popd

        ++ mv "ncurses-${VERSION}" "${PREFIX}/src"
      fi

      if [ -z "${SRC_PATH_2}" ]; then
        ++ tar -xvzf "ncurses-${VERSION}.tar.gz"

        ++ pushd "ncurses-${VERSION}"
        ++ ./configure \
          --prefix="${PREFIX}" \
          --with-normal \
          --with-shared \
          --enable-pc-files \
          --with-versioned-syms \
          --enable-widec
        ++ make
        ++ make install.includes
        ++ make install.libs
        ++ popd

        ++ mv "ncurses-${VERSION}" "${PREFIX}/src/ncursesw-${VERSION}"
      fi
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list ncurses >/dev/null 2>&1 && ++ brew uninstall ncurses
      elif [ "${COMMAND}" == "install" ]; then
        brew list ncurses >/dev/null 2>&1 || ++ brew install ncurses
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade ncurses
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libncurses-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libncurses-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libncurses-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove ncurses-devel ncurses
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install ncurses-devel ncurses
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update ncurses-devel ncurses
          fi
          ;;
      esac
      ;;
  esac
}

verify_version() {
  [[ $AVAILABLE_VERSIONS == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
