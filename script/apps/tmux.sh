#!/usr/bin/env bash
# based on https://gist.github.com/ryin/3106801#gistcomment-2191503
# tmux will be installed in ${PREFIX}/bin if you specify to install without root access


################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="tmux/tmux"

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
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "tmux-*")"

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

      ++ curl -LO "https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz"
      ++ tar -xvzf "tmux-${VERSION}.tar.gz"

      ++ pushd "tmux-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "tmux-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        # brew list reattach-to-user-namespace >/dev/null 2>&1 && ++ brew uninstall reattach-to-user-namespace
        brew list tmux >/dev/null 2>&1 && ++ brew uninstall tmux
      elif [ "${COMMAND}" == "install" ]; then
        brew list tmux >/dev/null 2>&1 || ++ brew install tmux
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade tmux
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove tmux
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install tmux
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install tmux
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove tmux
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install tmux
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update tmux
          fi
          ;;
      esac
      ;;
  esac

}

version_func() {
  $1 -V | awk '{print $2}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
