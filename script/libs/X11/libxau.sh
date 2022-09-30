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
    grep 'libXau' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libXau-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/libXau-* ]; then
      ++ pushd ${PREFIX}/src/libXau-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/libXau-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/libXau-* ]; then

      ++ curl -LO "https://www.x.org/archive/individual/lib/libXau-${VERSION}.tar.gz"
      ++ tar -xvzf "libXau-${VERSION}.tar.gz"

      ++ pushd "libXau-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "libXau-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list libxau >/dev/null 2>&1 && ++ brew uninstall libxau
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list libxau >/dev/null 2>&1 || ++ brew install libxau
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libxau
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libxau-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libxau-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libxau-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libXau-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install libXau-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libXau-devel
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

