#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://www.x.org/releases/individual/lib/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'libX11' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libX11-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "libX11-*")"


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

  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ -z "${SRC_PATH}" ]; then

      ++ curl -LO "https://www.x.org/releases/individual/lib/libX11-${VERSION}.tar.gz"
      ++ tar -xvzf "libX11-${VERSION}.tar.gz"

      ++ pushd "libX11-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "libX11-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list libx11 >/dev/null 2>&1 && ++ brew uninstall libx11
      elif [ "${COMMAND}" == "install" ]; then
        brew list libx11 >/dev/null 2>&1 || ++ brew install libx11
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libx11
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libx11-dev libx11-6
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libx11-dev libx11-6
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libx11-dev libx11-6
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libX11-devel libX11
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install libX11-devel libX11
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libX11-devel libX11
          fi
          ;;
      esac
      ;;
  esac

}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
