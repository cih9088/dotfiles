#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"
################################################################

setup_func_terminfo_local() {
  local FORCE=$1

  curl -LO --silent --show-error https://invisible-island.net/datafiles/current/terminfo.src.gz &&
   gunzip terminfo.src.gz || exit $?
  tic -xe alacritty-direct,tmux-256color terminfo.src || exit $?
}

main_script ${THIS} setup_func_terminfo_local setup_func_terminfo_local
