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
  curl --silent --show-error https://zlib.net/fossils/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/zlib-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/zlib-* ]; then
      ++ pushd ${PREFIX}/src/zlib-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/zlib-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/zlib-* ]; then
      [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

      ++ curl -LO "https://zlib.net/fossils/zlib-${VERSION}.tar.gz"
      ++ tar -xvzf "zlib-${VERSION}.tar.gz"

      ++ pushd "zlib-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "zlib-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list zlib >/dev/null 2>&1 && ++ brew uninstall zlib
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list zlib >/dev/null 2>&1 || ++ brew install zlib
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade zlib
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove zlib1g-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install zlib1g-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install zlib1g-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove zlib-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install zlib-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update zlib-devel
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
