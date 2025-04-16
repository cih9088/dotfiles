#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="Old-Man-Programmer/tree"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_tags" "${GH}")"
}

version_func() {
  $1 --version | awk '{print $2}'
}

verify_version() {
  local TARGET_VERSION="${1}"
  local AVAILABLE_VERSIONS="${2}"
  AVAILABLE_VERSIONS=$(echo "${AVAILABLE_VERSIONS}" | tr "\n\r" " ")
  [[ " ${AVAILABLE_VERSIONS} " == *" ${TARGET_VERSION} "* ]]
}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "tree-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      rm -rf "${PREFIX}/bin/tree"
      rm -rf "${PREFIX}/share/man/man1/tree.1"
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
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      ++ curl -LO "https://github.com/${GH}/archive/refs/tags/${VERSION}.tar.gz"
      ++ tar -xvzf "${VERSION}.tar.gz"

      ++ pushd "tree-${VERSION}"

      # for version lower than 2.0
      ++ sed -i -e "s|prefix = /usr|prefix = ${PREFIX}|" Makefile
      ++ sed -i -e "s|MANDIR=\${prefix}/man/man1|MANDIR=\${prefix}/share/man/man1|" Makefile
      # for version lower than 2.1.0
      ++ sed -i -e "s|prefix=/usr/local|prefix=${PREFIX}|" Makefile
      ++ sed -i -e "s|MANDIR=\${prefix}/man|MANDIR=\${prefix}/share/man/man1|" Makefile
      # newest
      ++ sed -i -e "s|PREFIX=/usr/local|PREFIX=${PREFIX}|" Makefile
      ++ sed -i -e "s|MANDIR=\${PREFIX}/man|MANDIR=\${PREFIX}/share/man/man1|" Makefile

      ++ make
      ++ make install
      ++ popd

      ++ mv "tree-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list tree >/dev/null 2>&1 && ++ brew uninstall tree
      elif [ "${COMMAND}" == "install" ]; then
        brew list tree >/dev/null 2>&1 || ++ brew install tree
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade tree
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove tree
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install tree
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install tree
          fi
          ;;
        centos|rocky)
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

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
