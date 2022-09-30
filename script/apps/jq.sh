#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="stedolan/jq"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_up_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/jq-* ]; then
      ++ pushd ${PREFIX}/src/jq-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/jq-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/jq-* ]; then

      ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/${VERSION}.tar.gz"
      ++ tar -xvzf "${VERSION}.tar.gz"

      ++ pushd "${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_up_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list jq >/dev/null 2>&1 && ++ brew uninstall jq
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list jq >/dev/null 2>&1 || ++ brew install jq
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade jq
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove jq
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install jq
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install jq
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove jq
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install jq
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update jq
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

