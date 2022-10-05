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
  curl --silent --show-error https://gnupg.org/ftp/gcrypt/libgcrypt/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.bz2\"' |
    awk '{print $4}' |
    sed -e 's/.tar.bz2//' -e 's/libgcrypt-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "libgcrypt-*")"


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

      ++ curl -LO "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
      ++ tar -xvjf "libgcrypt-${VERSION}.tar.bz2"

      ++ pushd "libgcrypt-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "libgcrypt-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list libgcrypt >/dev/null 2>&1 && ++ brew uninstall libgcrypt
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list libgcrypt >/dev/null 2>&1 || ++ brew install libgcrypt
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade libgcrypt
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libgcrypt20-dev libgcrypt20
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libgcrypt20-dev libgcrypt20
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libgcrypt20-dev libgcrypt20
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove libgcrypt-devel libgcrypt
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install libgcrypt-devel libgcrypt
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update libgcrypt-devel libgcrypt
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
