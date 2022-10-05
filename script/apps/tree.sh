#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION=1.8.0
################################################################


setup_func_tree_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "tree-*")"

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

      ++ curl -LO "http://mama.indstate.edu/users/ice/tree/src/tree-${VERSION}.tgz"
      ++ tar -xvzf "tree-${VERSION}.tgz"

      ++ pushd "tree-${VERSION}"
      ++ sed -i -e "s|prefix = /usr|prefix = ${PREFIX}|" Makefile
      ++ sed -i -e "s|MANDIR=\${prefix}/man/man1|MANDIR=\${prefix}/share/man/man1|" Makefile
      ++ make
      ++ make install
      ++ popd

      ++ mv "tree-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_tree_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list tree >/dev/null 2>&1 && ++ brew uninstall tree
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list tree >/dev/null 2>&1 || ++ brew install tree
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade tree
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove tree
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install tree
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install tree
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove tree
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install tree
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update tree
          fi
          ;;
      esac
      ;;
  esac

}

version_func_tree() {
  $1 --version | awk '{print $2}'
}

main_script ${THIS} setup_func_tree_local setup_func_tree_system version_func_tree \
  "${DEFAULT_VERSION}"
