#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  curl --silent --show-error https://ftp.gnu.org/pub/gnu/ncurses/ \
    | ${DIR}/../helpers/parser_html 'a' \
    | grep 'ncurses' | grep 'tar.gz\"' \
    | awk '{print $4}' \
    | sed -e 's/.tar.gz//' -e 's/ncurses-//' \
    | sort -Vr
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
  local SRC_PATH_2=""
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
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      ++ curl -LO "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${VERSION}.tar.gz"

      if [ -z "${SRC_PATH}" ]; then
        ++ tar -xvzf "ncurses-${VERSION}.tar.gz"

        ++ pushd "ncurses-${VERSION}"
        ++ ./configure \
          --prefix="${PREFIX}" \
          --with-normal \
          --with-shared \
          --without-debug \
          --enable-pc-files \
          --with-versioned-syms \
          --disable-widec
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
          --without-debug \
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

setup_for_system() {
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
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libncurses-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libncurses-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libncurses-dev
          fi
          ;;
        centos|rocky)
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

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
