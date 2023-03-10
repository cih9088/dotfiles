#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=lua-env
GH="JohnnyMorganz/StyLua"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=stylua

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
  [ -z "${VERSION}" ] && VERSION="$(list_versions | head -n 1)"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/stylua" ]; then
      rm -rf "${PREFIX}/bin/stylua" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/stylua" ]; then
     if [[ ${PLATFORM} == "OSX" ]]; then
        ++ curl -LO "https://github.com/JohnnyMorganz/StyLua/releases/download/${VERSION}/stylua-macos.zip"
        ++ unzip stylua-macos.zip
      elif [[ ${PLATFORM} == "LINUX" ]]; then
        ++ curl -LO "https://github.com/JohnnyMorganz/StyLua/releases/download/${VERSION}/stylua-linux.zip"
        ++ unzip stylua-linux.zip
      fi
      ++ chmod +x stylua
      ++ cp stylua "${PREFIX}/bin"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"
  local VERSION="$(list_versions | head -n 1)"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list stylua >/dev/null 2>&1 && ++ brew uninstall stylua
      elif [ "${COMMAND}" == "install" ]; then
        brew list stylua >/dev/null 2>&1 || ++ brew install stylua
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade stylua
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -f /usr/local/bin/stylua
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        ++ curl -LO "https://github.com/JohnnyMorganz/StyLua/releases/download/${VERSION}/stylua-linux.zip"
        ++ unzip stylua-linux.zip
        ++ chmod +x stylua
        ++ sudo mkdir -p /usr/local/bin
        ++ sudo cp stylua /usr/local/bin/
      fi
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
