#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install tldr${Color_Off}"
################################################################

setup_func_tldr_local() {
    force=$1
    cd $TMP_DIR

    if [ ${force} == 'true' ]; then
        pip install tldr --user --force-reinstall --upgrade
    else
        pip install tldr --user
    fi
}

setup_func_tldr_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew list tldr || brew install tldr
        if [ ${force} == 'true' ]; then
            brew upgrade tldr
        fi
    elif [[ $platform == "LINUX" ]]; then
        if [ ${force} == 'true' ]; then
            sudo pip install tldr --upgrade --force-reinstall
        else
            sudo pip install tldr
        fi
    fi
}

main_script 'tldr' setup_func_tldr_local setup_func_tldr_system
