#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  curl --silent --show-error https://ftp.gnu.org/pub/gnu/glibc/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'glibc-[0-9]\+' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/glibc-//' |
    sort -Vr
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "glibc-*")"

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
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      ++ curl -LO "https://ftp.gnu.org/pub/gnu/glibc/glibc-${VERSION}.tar.gz"
      ++ tar -xvzf "glibc-${VERSION}.tar.gz"

      ++ pushd "glibc-${VERSION}"
      ++ curl -LO https://ftp.gnu.org/pub/gnu/glibc/glibc-linuxthreads-2.5.tar.bz2
      ++ tar -xvf glibc-linuxthreads-2.5.tar.bz2
      ++ mkdir build
      ++ pushd build
      ++ ../configure --prefix="${PREFIX}" --enable-add-ons=linuxthreads
      ++ make
      ++ make install
      ++ popd && ++ popd

      ++ mv "glibc-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list glibc >/dev/null 2>&1 && ++ brew uninstall glibc
      elif [ "${COMMAND}" == "install" ]; then
        brew list glibc >/dev/null 2>&1 || ++ brew install glibc
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade glibc
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libglib2.0-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libglib2.0-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libglib2.0-dev
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove glibc-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install glibc-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update glibc-devel
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
