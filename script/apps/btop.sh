#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="aristocratos/btop"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "btop-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}"
      make uninstall || true
      make clean || true
      ++ popd
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
      if [ $PLATFORM != LINUX ]; then
        log_error "${COMMAND} ${THIS_HL} is not supported in ${PLATFORM}"
        exit 1
      fi

      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/btop-${ARCH}-linux-musl.tbz"
      ++ tar -xvjf "btop-${ARCH}-linux-musl.tbz"

      ++ pushd "btop"
      ++ make install
      ++ popd

      ++ mv "btop" "${PREFIX}/src/btop-${VERSION}"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list btop >/dev/null 2>&1 && ++ brew uninstall btop
      elif [ "${COMMAND}" == "install" ]; then
        brew list btop >/dev/null 2>&1 || ++ brew install btop
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade btop
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          log_info "Not able to ${COMMAND} ${THIS} systemwide."
          setup_for_local "${COMMAND}"
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove btop
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install epel-release
            ++ sudo dnf -y install btop
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update btop
          fi
          ;;
      esac
      ;;
  esac

}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func

