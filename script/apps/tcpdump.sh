#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="the-tcpdump-group/tcpdump"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  ${DIR}/../helpers/gh_list_tags ${GH} | 
    sed 's/tcpdump-//' | tr ' ' '\n' | 
    grep -v 'bp' | grep -v 'rc')"
DEFAULT_VERSION="$(echo ${AVAILABLE_VERSIONS} | awk '{print $1}')"
################################################################

setup_func_up_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "tcpdump-*")"

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

      ++ curl -LO "https://github.com/${GH}/archive/refs/tags/tcpdump-${VERSION}.tar.gz"
      ++ tar -xvzf "tcpdump-${VERSION}.tar.gz"

      ++ pushd "tcpdump-tcpdump-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "tcpdump-tcpdump-${VERSION}" "${PREFIX}/src/tcpdump-${VERSION}"
    fi
  fi
}

setup_func_up_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list tcpdump >/dev/null 2>&1 && ++ brew uninstall tcpdump
      elif [ "${COMMAND}" == "install" ]; then
        brew list tcpdump >/dev/null 2>&1 || ++ brew install tcpdump
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade tcpdump
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove tcpdump
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install tcpdump
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install tcpdump
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove tcpdump
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install tcpdump
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update tcpdump
          fi
          ;;
      esac
      ;;
  esac

}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_up_local setup_func_up_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

