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
  curl --silent --show-error https://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    awk '{print $5}' |
    grep -v '[a-z]' |
    sort -Vr
}

version_func() {
  $1 -h | head -1 | cut -d ',' -f1
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
  [ -z "${VERSION}" ] && VERSION="$(list_versions | head -n 1)"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "unzip*")"

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

      ++ curl -L "https://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/UnZip%20${VERSION}/unzip${VERSION/./}.tar.gz/download" \
        -o unzip${VERSION/./}.tar.gz
      ++ tar -xvzf "unzip${VERSION/./}.tar.gz"

      ++ pushd "unzip${VERSION/./}"
      ++ make -f unix/Makefile generic
      ++ make prefix="${PREFIX}" MANDIR="${PREFIX}"/share/man/man1 -f unix/Makefile install
      ++ popd

      ++ mv "unzip${VERSION/./}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list unzip >/dev/null 2>&1 && ++ brew uninstall unzip
      elif [ "${COMMAND}" == "install" ]; then
        brew list unzip >/dev/null 2>&1 || ++ brew install unzip
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade unzip
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove unzip
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install unzip
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install unzip
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove unzip
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install unzip
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update unzip
          fi
          ;;
      esac
      ;;
  esac

}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
