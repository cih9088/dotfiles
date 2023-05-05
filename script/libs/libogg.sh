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
  curl --silent https://ftp.osuosl.org/pub/xiph/releases/ogg/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz' |
    awk '{print $NF}' |
    grep -v 'rc' |
    grep -v 'beta' |
    sed -e 's/libogg-//' -e 's/.tar.gz//' |
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
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "libogg-*")"


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

      ++ curl -LO "https://downloads.xiph.org/releases/ogg/libogg-${VERSION}.tar.gz"
      ++ tar -xvzf "libogg-${VERSION}.tar.gz"

      ++ pushd "libogg-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "libogg-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list libogg >/dev/null 2>&1 && ++ brew uninstall libogg
      elif [ "${COMMAND}" == "install" ]; then
        brew list libogg >/dev/null 2>&1 || ++ brew install libogg
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libogg
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libogg-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libogg-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libogg-dev
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libogg
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install libogg
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libogg
          fi
          ;;
      esac
      ;;
  esac

}


main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
