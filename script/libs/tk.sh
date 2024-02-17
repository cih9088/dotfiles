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
  _VERSIONS=$(curl --silent --show-error https://sourceforge.net/projects/tcl/files/Tcl/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    awk '{print $4}' |
    grep -v '[a-z]' |
    sort -Vr
  )

  # the latest version directory is sometimes not a release
  if ! curl --silent "https://sourceforge.net/projects/tcl/files/Tcl/$(echo ${_VERSIONS} |
    awk '{print $1}')/" |
    grep -q 'Releases'
  then
    _VERSIONS=$(echo "$_VERSIONS" | tail -n +2)
  fi
  echo "${_VERSIONS}"
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "tk*")"

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
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      ++ curl -L "https://sourceforge.net/projects/tcl/files/Tcl/${VERSION}/tk${VERSION}-src.tar.gz/download" \
        -o "tk${VERSION}-src.tar.gz"
      ++ tar -xvzf "tk${VERSION}-src.tar.gz"

      ++ pushd "tk${VERSION}"
      if [[ ${PLATFORM} == "OSX" ]]; then
        ++ pushd macosx
      elif [[ ${PLATFORM} == "LINUX" ]]; then
        ++ pushd unix
      fi
      ++ ./configure --prefix="${PREFIX}" --mandir="${PREFIX}/share/man"
      ++ make
      ++ make install
      ++ popd; ++ popd;

      mv "tk${VERSION}" "${PREFIX}/src"
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
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove tk-dev tk
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install tk-dev tk
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install tk-dev tk
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove tk-devel tk
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install tk-devel tk
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update tk-devel tk
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
