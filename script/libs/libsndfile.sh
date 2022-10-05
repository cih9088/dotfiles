#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error http://www.mega-nerd.com/libsndfile/files/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep '"libsndfile-[0-9]' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libsndfile-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "libsndfile-*")"

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

      ++ curl -LO "http://www.mega-nerd.com/libsndfile/files/libsndfile-${VERSION}.tar.gz"
      ++ tar -xvzf "libsndfile-${VERSION}.tar.gz"

      ++ pushd "libsndfile-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "libsndfile-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list libsndfile >/dev/null 2>&1 && ++ brew uninstall libsndfile
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list libsndfile >/dev/null 2>&1 || ++ brew install libsndfile
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libsndfile
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libsndfile-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libsndfile-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libsndfile-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libsndfile
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install libsndfile
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libsndfile
          fi
          ;;
      esac
      ;;
  esac

}


main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" ""

