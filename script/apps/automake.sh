#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/gnu/automake/ \
    | ${DIR}/../helpers/parser_html 'a' \
    | grep 'tar.gz\"' \
    | awk '{print $4}' \
    | sed -e 's/.tar.gz//' -e 's/automake-//' \
    | sort -Vr
)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1)
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update" == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/automake-* ]; then
      ++ pushd ${PREFIX}/src/automake-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/automake-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update" == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/automake-* ]; then

      ++ curl -LO "https://ftp.gnu.org/gnu/automake/automake-${VERSION}.tar.gz"
      ++ tar -xvzf "automake-${VERSION}.tar.gz"

      ++ pushd "automake-${VERSION}"
      ++ ./configure --prefix"=${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "automake-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list automake >/dev/null 2>&1 && ++ brew uninstall automake
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list automake >/dev/null 2>&1 || ++ brew install automake
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade automake
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove automake
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install automake
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install automake
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove automake
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install automake
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update automake
          fi
          ;;
      esac
      ;;
  esac
}

version_func() {
  $1 --version | grep '(GNU' | awk '{print $4}'
}

verify_version() {
  [[ $AVAILABLE_VERSIONS == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
