#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="kkos/oniguruma"

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
    if [ -d ${PREFIX}/src/onig-* ]; then
      ++ pushd ${PREFIX}/src/onig-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/onig-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/onig-* ]; then

      ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/onig-${VERSION##v}.tar.gz"
      ++ tar -xvzf "onig-${VERSION##v}.tar.gz"

      ++ pushd "onig-${VERSION##v}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "onig-${VERSION##v}" "${PREFIX}/src"
    fi
  fi
}

setup_func_up_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list oniguruma >/dev/null 2>&1 && ++ brew uninstall oniguruma
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list oniguruma >/dev/null 2>&1 || ++ brew install oniguruma
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade oniguruma
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libonig5
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libonig5
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libonig5
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove oniguruma
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install oniguruma
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update oniguruma
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
