#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="libffi/libffi"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH} | grep -v 'rc')"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/libffi-* ]; then
      ++ pushd ${PREFIX}/src/libffi-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/libffi-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d ${PREFIX}/src/libffi-* ]; then

      ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/libffi-${VERSION##v}.tar.gz"
      ++ tar -xvzf "libffi-${VERSION##v}.tar.gz"

      ++ pushd "libffi-${VERSION##v}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "libffi-${VERSION##v}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list libffi >/dev/null 2>&1 && ++ brew uninstall libffi
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list libffi >/dev/null 2>&1 || ++ brew install libffi
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libffi
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libffi-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libffi-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libffi-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libffi-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install libffi-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libffi-devel
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
