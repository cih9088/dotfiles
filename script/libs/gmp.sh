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
  curl --silent --show-error https://gmplib.org/download/gmp/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.xz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.xz//' -e 's/gmp-//' |
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "gmp-*")"

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

      ++ curl -LO "https://gmplib.org/download/gmp/gmp-${VERSION}.tar.xz"
      ++ tar -xvJf "gmp-${VERSION}.tar.xz"

      ++ pushd "gmp-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make check
      ++ make install
      ++ popd

      ++ mv "gmp-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list nettle >/dev/null 2>&1 && ++ brew uninstall nettle
      elif [ "${COMMAND}" == "install" ]; then
        brew list nettle >/dev/null 2>&1 || ++ brew install nettle
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade nettle
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove nettle-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install nettle-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install nettle-dev
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove nettle-devel nettle
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install nettle-devel nettle
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update nettle-devel nettle
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
