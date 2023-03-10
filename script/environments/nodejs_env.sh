#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

has -v npm

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"
################################################################

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=latest

  if [ "${COMMAND}" == "remove" ]; then
    ++ npm uninstall --global prettier
    ++ npm uninstall --global yarn
    ++ npm uninstall --global typescript
  elif [ "${COMMAND}" == "install" ]; then
    ++ npm install --global prettier
    ++ npm install --global yarn
    ++ npm install --global typescript
  elif [ "${COMMAND}" == "update" ]; then
    ++ npm update --global prettier
    ++ npm update --global yarn
    ++ npm update --global typescript
  fi
  has asdf && asdf reshim nodejs || true
}

main_script "${THIS}" \
  setup_for_local "" \
  "" "" ""
