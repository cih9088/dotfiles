#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=stylua

log_title "Prepare to install ${THIS_HL}"

################################################################

setup_func_stylua_local() {

  local FORCE="${1}"

  local STYLUA_VERSION="$(${DIR}/../helpers/gh_get_latest_release JohnnyMorganz/StyLua)"
  if [[ ${PLATFORM} == "OSX" ]]; then
    curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/stylua-macos.zip || exit $?
    unzip stylua-macos.zip || exit $?
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/stylua-linux.zip || exit $?
    unzip stylua-linux.zip || exit $?
  fi
  chmod +x stylua || exit $?
  \cp -rf stylua ${PREFIX}/bin || exit $?
}

version_func_stylua() {
  $1 --version | awk '{print $2}'
}

main_script ${THIS} setup_func_stylua_local setup_func_stylua_local version_func_stylua
