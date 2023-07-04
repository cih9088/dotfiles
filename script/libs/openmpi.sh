#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="open-mpi/ompi"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_tags" "${GH}")" |
    grep -v "rc" |
    sort -Vr |
    uniq
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "openmpi-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}/build"
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

      ++ curl -LO "https://download.open-mpi.org/release/open-mpi/$(echo $VERSION | grep -o 'v[0-9]\+\.[0-9]\+')/openmpi-${VERSION#v}.tar.gz"
      ++ tar -xvf "openmpi-${VERSION#v}.tar.gz"

      ++ pushd "openmpi-${VERSION#v}"
      ++ mkdir build
      ++ pushd build
      ++ ../configure --prefix="${PREFIX}"
      ++ make all
      ++ make install
      ++ popd
      ++ popd

      ++ mv "openmpi-${VERSION#v}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list open-mpi >/dev/null 2>&1 && ++ brew uninstall open-mpi
      elif [ "${COMMAND}" == "install" ]; then
        brew list open-mpi >/dev/null 2>&1 || ++ brew install open-mpi
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade open-mpi
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove openmpi-bin openmpi-common libopenmpi-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install openmpi-bin openmpi-common libopenmpi-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install openmpi-bin openmpi-common libopenmpi-dev
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove openmpi openmpi-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install epel-release
            ++ sudo dnf -y install openmpi openmpi-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update openmpi openmpi-devel
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
