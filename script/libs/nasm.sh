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
  curl --silent --show-error https://www.nasm.us/pub/nasm/releasebuilds/ |
    ${DIR}/../helpers/parser_html 'a' |
    cut -f 4- -d ' ' |
    grep -v '[a-zA-Z]' |
    sed -e 's/\///' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "nasm-*")"

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

      ++ curl -LO "https://www.nasm.us/pub/nasm/releasebuilds/${VERSION}/nasm-${VERSION}.tar.gz"
      ++ tar -xvzf "nasm-${VERSION}.tar.gz"

      ++ pushd "nasm-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "nasm-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list nasm >/dev/null 2>&1 && ++ brew uninstall nasm
      elif [ "${COMMAND}" == "install" ]; then
        brew list nasm >/dev/null 2>&1 || ++ brew install nasm
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade nasm
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove nasm
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install nasm
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install nasm
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove nasm
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install dnf-plugins-core
            if dnf repolist --all | grep -q -i crb; then
              ++ sudo dnf config-manager --set-enabled crb
            elif dnf repolist --all | grep -q -i powertools; then
              ++ sudo dnf config-manager --set-enabled powertools
            fi
            ++ sudo dnf -y install nasm
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update nasm
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