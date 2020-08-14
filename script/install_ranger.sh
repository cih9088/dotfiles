#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to install ranger"
################################################################

setup_func_ranger_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -f ${HOME}/.local/bin/ranger ]; then
        if [ ${force} == 'true' ]; then
            rm -rf $HOME/.local/src/ranger || true
            rm -rf $HOME/.local/bin/ranger || true
            install=true
        fi
    else
        install=true
    fi

    if [ ${install} == 'true' ]; then
        git clone https://github.com/ranger/ranger.git $HOME/.local/src/ranger
        # git clone https://github.com/cih9088/ranger $HOME/.local/src/ranger
        $HOME/.local/src/ranger/ranger.py --copy-config=all
        ln -sf $HOME/.local/src/ranger/ranger.py $HOME/.local/bin/ranger
    fi
}

setup_func_ranger_system() {
    setup_func_ranger_local $1
}

version_func_ranger() {
    $1 --version | head -1 | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'ranger' setup_func_ranger_local setup_func_ranger_system version_func_ranger
