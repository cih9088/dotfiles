#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="mvdan/sh"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=shfmt

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
}

version_func() {
  $1 -version
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
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/shfmt" ]; then
      rm -rf "${PREFIX}/bin/shfmt" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/shfmt" ]; then

      if [ "${ARCH}" == "x86_64" ]; then
        _ARCH=amd64
      elif [ "${ARCH}" == "aarch64" ]; then
        _ARCH=arm64
      fi

      if [[ ${PLATFORM} == "OSX" ]]; then
        # does not have aarch64 for apple
        ++ curl -LO "https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_darwin_${_ARCH}"
        ++ chmod +x "shfmt_${VERSION}_darwin_${_ARCH}"
        ++ cp "shfmt_${VERSION}_darwin_${_ARCH}" "${PREFIX}/bin/shfmt"
      elif [[ ${PLATFORM} == "LINUX" ]]; then
        ++ curl -LO "https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_linux_${_ARCH}"
        ++ chmod +x "shfmt_${VERSION}_linux_${_ARCH}"
        ++ cp "shfmt_${VERSION}_linux_${_ARCH}" "${PREFIX}/bin/shfmt"
      fi
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"
  local VERSION="$(list_versions | head -n 1)"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list shfmt >/dev/null 2>&1 && ++ brew uninstall shfmt
      elif [ "${COMMAND}" == "install" ]; then
        brew list shfmt >/dev/null 2>&1 || ++ brew install shfmt
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade shfmt
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -f /usr/local/bin/shfmt
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        if [ "${ARCH}" == "x86_64" ]; then
          _ARCH=amd64
        elif [ "${ARCH}" == "aarch64" ]; then
          _ARCH=arm64
        fi
        ++ curl -LO "https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_linux_${_ARCH}"
        ++ chmod +x "shfmt_${VERSION}_linux_${_ARCH}"
        ++ sudo mkdir -p /usr/local/bin
        ++ sudo cp "shfmt_${VERSION}_linux_${_ARCH}" /usr/local/bin/shfmt
      fi
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
