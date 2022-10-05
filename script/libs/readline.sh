#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/gnu/readline/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep -v 'doc' | grep -v 'rc' | grep -v 'alph' | grep -v 'beta' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/readline-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "readline-*")"


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

      ++ curl -LO "https://ftp.gnu.org/gnu/readline/readline-${VERSION}.tar.gz"
      ++ tar -xvzf "readline-${VERSION}.tar.gz"

      ++ pushd "readline-${VERSION}"
      ++ ./configure --prefix="${PREFIX}" --enable-shared
      # https://lists.gnu.org/archive/html/bug-readline/2017-10/msg00007.html
      ++ make SHLIB_LIBS="-lncurses"
      ++ make install
      ++ popd

      ++ mv "readline-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list readline >/dev/null 2>&1 && ++ brew uninstall readline
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list readline >/dev/null 2>&1 || ++ brew install readline
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade readline
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libreadline-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libreadline-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libreadline-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove readline-devel readline
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install readline-devel readline
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update readline-devel readline
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
