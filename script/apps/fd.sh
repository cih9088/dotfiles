#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="sharkdp/fd"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f ${PREFIX}/bin/fd ]; then
      rm -rf ${PREFIX}/bin/fd || true
      rm -rf ${PREFIX}/share/man/man1/fd.1 || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f ${PREFIX}/bin/fd ]; then

      case ${PLATFORM} in
        OSX )
          # does not have aarch64 for apple
          ++ curl -LO https://github.com/${GH}/releases/download/${VERSION}/fd-${VERSION}-x86_64-apple-darwin.tar.gz
          ++ tar -xvzf fd-${VERSION}-x86_64-apple-darwin.tar.gz

          ++ pushd fd-${VERSION}-x86_64-apple-darwin
          ++ yes | \cp -rf fd ${PREFIX}/bin
          ++ yes | \cp -rf fd.1 ${PREFIX}/sahre/man/man1
          ++ popd
          ;;
        LINUX )
          ++ curl -LO https://github.com/${GH}/releases/download/${VERSION}/fd-${VERSION}-${ARCH}-unknown-linux-gnu.tar.gz
          ++ tar -xvzf fd-${VERSION}-${ARCH}-unknown-linux-gnu.tar.gz

          ++ pushd fd-${VERSION}-${ARCH}-unknown-linux-gnu
          ++ yes | \cp -rf fd ${PREFIX}/bin
          ++ yes | \cp -rf fd.1 ${PREFIX}/share/man/man1
          ++ popd
          ;;
      esac
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list fd >/dev/null 2>&1 && ++ brew uninstall fd
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list fd >/dev/null 2>&1 || ++ brew install fd
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade fd
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove fd-find
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install fd-find
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install fd-find
          fi
          ;;
        RHEL)
            log_error "No package in repository. Please install it in local mode"
            exit 1
          ;;
      esac
      ;;
  esac

}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
