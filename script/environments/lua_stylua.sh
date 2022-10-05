#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=lua-env

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=stylua

log_title "Prepare for ${THIS_HL}"

################################################################

setup_func_stylua_local() {
  local COMMAND="${1:-skip}"
  local STYLUA_VERSION="$(${DIR}/../helpers/gh_get_latest_release JohnnyMorganz/StyLua)"

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
        ++ curl -LO "https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/stylua-macos.zip"
        ++ unzip stylua-macos.zip
      elif [[ ${PLATFORM} == "LINUX" ]]; then
        ++ curl -LO "https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/stylua-linux.zip"
        ++ unzip stylua-linux.zip
      fi
      ++ chmod +x stylua
      ++ cp stylua "${PREFIX}/bin"
    fi
  fi
}

setup_func_stylua_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list stylua >/dev/null 2>&1 && ++ brew uninstall stylua
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list stylua >/dev/null 2>&1 || ++ brew install stylua
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade stylua
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -f /usr/local/bin/stylua
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        ++ curl -LO "https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/stylua-linux.zip"
        ++ unzip stylua-linux.zip
        ++ chmod +x stylua
        ++ sudo mkdir -p /usr/local/bin
        ++ sudo cp stylua /usr/local/bin/
      fi
      ;;
  esac
}

version_func_stylua() {
  $1 --version | awk '{print $2}'
}

main_script ${THIS} setup_func_stylua_local setup_func_stylua_local version_func_stylua
