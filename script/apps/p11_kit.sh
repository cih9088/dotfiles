#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="p11-glue/p11-kit"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/gp11-kit-* ]; then
      ++ pushd ${PREFIX}/src/gp11-kit-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/gp11-kit-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/gp11-kit-* ]; then

      ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/p11-kit-${VERSION}.tar.xz"
      ++ tar -xvJf "p11-kit-${VERSION}.tar.xz"

      ++ pushd "p11-kit-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "p11-kit-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list p11-kit >/dev/null 2>&1 && ++ brew uninstall p11-kit
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list p11-kit >/dev/null 2>&1 || ++ brew install p11-kit
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade p11-kit
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libp11-kit-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libp11-kit-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libp11-kit-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove p11-kit-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install p11-kit-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update p11-kit-devel
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
