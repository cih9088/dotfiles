#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install terminfo${Color_Off}"
################################################################

setup_func_terminfo_local() {
    force=$1
    cd $TMP_DIR

    curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz
    tic -xe alacritty-direct,tmux-256color terminfo.src
}

setup_func_terminfo_system() {
    setup_func_terminfo_local $1
}

main_script 'terminfo' setup_func_terminfo_local setup_func_terminfo_system
