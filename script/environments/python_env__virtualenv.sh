#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=virtualenv

log_title "Prepare for ${THIS_HL}"
################################################################

version_funcn() {
  $1 --version | awk '{print $2}'
}

setup_for_local() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "install" ]; then
    ++ intelli_pip3 install virtualenv virtualenvwrapper
  elif [ "${COMMAND}" == "update" ]; then
    ++ intelli_pip3 install virtualenv virtualenvwrapper --force-reinstall --upgrade
  elif [ "${COMMAND}" == "remove" ]; then
    ++ intelli_pip3 uninstall --yes virtualenv virtualenvwrapper
  fi
}

main_script "${THIS}" \
  setup_for_local "" \
  "" "" version_funcn

(
  has asdf && asdf reshim python || true
  has pyenv && pyenv ++ rehash || true
) >&3 2>&4
