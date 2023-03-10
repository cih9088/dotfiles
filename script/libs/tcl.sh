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
  curl --silent --show-error https://sourceforge.net/projects/tcl/files/Tcl/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    awk '{print $4}' |
    grep -v '[a-z]' |
    sort -Vr
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "tcl*")"

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

      ++ curl -L "https://sourceforge.net/projects/tcl/files/Tcl/${VERSION}/tcl${VERSION}-src.tar.gz/download" \
        -o "tcl${VERSION}-src.tar.gz"
      ++ tar -xvzf "tcl${VERSION}-src.tar.gz"

      ++ pushd "tcl${VERSION}"
      if [[ ${PLATFORM} == "OSX" ]]; then
        ++ pushd macosx
      elif [[ ${PLATFORM} == "LINUX" ]]; then
        ++ pushd unix
      fi
      ++ ./configure --prefix="${PREFIX}" --mandir="${PREFIX}/share/man"
      ++ make
      ++ make install
      ++ popd; ++ popd;

      ++ mv "tcl${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list tcl-tk >/dev/null 2>&1 && ++ brew uninstall tcl-tk
      elif [ "${COMMAND}" == "install" ]; then
        brew list tcl-tk >/dev/null 2>&1 || ++ brew install tcl-tk
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade tcl-tk
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove tcl-dev tcl
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install tcl-dev tcl
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install tcl-dev tcl
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove tcl-devel tcl
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install tcl-devel tcl
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update tcl-devel tcl
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
