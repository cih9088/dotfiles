#!/usr/bin/env bash
# Original repo of ripgrep is https://github.com/BurntSushi/ripgrep
# but it has limited number of pre-built binaries.
# This script will download pre-built binary from microsoft.

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="microsoft/ripgrep-prebuilt"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_rg_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f ${PREFIX}/bin/rg ]; then
      rm -rf ${PREFIX}/bin/rg || true
      rm -rf ${PREFIX}/share/man/man1/rg.1 || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f ${PREFIX}/bin/rg ]; then
      [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

      case ${PLATFORM} in
        OSX )
          # does not have aarch64 for apple
          ++ curl -LO https://github.com/microsoft/ripgrep-prebuilt/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz
          ++ tar -xvzf ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz

          \cp -rf rg ${PREFIX}/bin
          ;;
        LINUX )
          ++ curl -LO https://github.com/microsoft/ripgrep-prebuilt/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz
          ++ tar -xvzf ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz

          \cp -rf rg ${PREFIX}/bin
          ;;
      esac
    fi
  fi
}

setup_func_rg_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list ripgrep >/dev/null 2>&1 && ++ brew uninstall ripgrep
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list ripgrep >/dev/null 2>&1 || ++ brew install ripgrep
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade ripgrep
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove ripgrep
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install ripgrep
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install ripgrep
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

version_func_rg() {
  $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_rg_local setup_func_rg_system version_func_rg \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
