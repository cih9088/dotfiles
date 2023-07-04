#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD="iconv"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  curl --silent --show-error https://ftp.gnu.org/gnu/libiconv/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libiconv-//' |
    sort -Vr
}

version_func() {
  $1 --version | head -1 | cut -d ' ' -f4
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "libiconv-*")"

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

      ++ curl -LO "https://ftp.gnu.org/gnu/libiconv/libiconv-${VERSION}.tar.gz"
      ++ tar -xvzf "libiconv-${VERSION}.tar.gz"

      ++ pushd "libiconv-${VERSION}"
      ++ ./configure --prefix=${PREFIX}
      ++ make
      ++ make install
      ++ popd

      ++ mv "libiconv-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list libiconv >/dev/null 2>&1 && ++ brew uninstall libiconv
      elif [ "${COMMAND}" == "install" ]; then
        brew list libiconv >/dev/null 2>&1 || ++ brew install libiconv
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libiconv
      fi
      ;;
    LINUX)
      PREFIX=/usr/local
      wrap_sudo make rm mv
      setup_for_local "${COMMAND}"
      unwrap make rm mv
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
