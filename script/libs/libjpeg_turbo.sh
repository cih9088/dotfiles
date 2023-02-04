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
  curl --silent --show-error https://sourceforge.net/projects/libjpeg-turbo/files/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    cut -f 4- -d ' ' |
    grep -v '[a-zA-Z]' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "libjpeg-turbo-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}/build"
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

      ++ curl -L "https://sourceforge.net/projects/libjpeg-turbo/files/${VERSION}/libjpeg-turbo-${VERSION}.tar.gz/download" \
        -o "libjpeg-turbo-${VERSION}.tar.gz"
      ++ tar -xvzf "libjpeg-turbo-${VERSION}.tar.gz"

      ++ pushd "libjpeg-turbo-${VERSION}"
      ++ mkdir -p build
      ++ pushd build
      ++ cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=RELEASE
      ++ make
      ++ make install
      ++ popd; ++ popd;

      mv "libjpeg-turbo-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list jpeg-turbo >/dev/null 2>&1 && ++ brew uninstall jpeg-turbo
      elif [ "${COMMAND}" == "install" ]; then
        brew list jpeg-turbo >/dev/null 2>&1 || ++ brew install jpeg-turbo
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade jpeg-turbo
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libturbojpeg
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libturbojpeg
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libturbojpeg
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libjpeg-turbo-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install libjpeg-turbo-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libjpeg-turbo-devel
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