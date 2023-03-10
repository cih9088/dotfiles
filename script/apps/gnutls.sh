#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  # latest version is not stable release but next release
  curl --silent --show-error https://www.gnupg.org/ftp/gcrypt/gnutls/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep '\"v' |
    awk '{print $4}' |
    sort -Vr | sed '1d'
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
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "gnutls-*")"

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

      _FINAL_VERSION="$(curl --silent --show-error https://www.gnupg.org/ftp/gcrypt/gnutls/${VERSION}/ |
        ${DIR}/../helpers/parser_html 'a' |
        grep 'tar.xz\"' |
        awk '{print $4}' |
        sed -e 's/.tar.xz//' -e 's/gnutls-//' |
        sort -Vr | head -n 1)"

      ++ curl -LO "https://www.gnupg.org/ftp/gcrypt/gnutls/${VERSION}/gnutls-${_FINAL_VERSION}.tar.xz"
      ++ tar -xvJf "gnutls-${_FINAL_VERSION}.tar.xz"

      ++ pushd "gnutls-${_FINAL_VERSION}"
      ++ ./configure --prefix="${PREFIX}" --with-included-unistring
      ++ make
      ++ make install
      ++ popd

      ++ mv "gnutls-${_FINAL_VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list gnutls >/dev/null 2>&1 && ++ brew uninstall gnutls
      elif [ "${COMMAND}" == "install" ]; then
        brew list gnutls >/dev/null 2>&1 || ++ brew install gnutls
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade gnutls
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove gnutls-bin libgnutls28-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install gnutls-bin libgnutls28-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install gnutls-bin libgnutls28-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove gnutls-devel gnutls
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install gnutls-devel gnutls
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update gnutls-devel gnutls
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
