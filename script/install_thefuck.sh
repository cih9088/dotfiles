#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install thefuck${Color_Off}"
################################################################

setup_func_thefuck_local() {
    force=$1
    cd $TMP_DIR

    if [ ${force} == 'true' ]; then
        pip3 install thefuck --user --force-reinstall --upgrade
    else
        pip3 install thefuck --user
    fi
}

setup_func_thefuck_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew list thefuck || brew install thefuck
        if [ ${force} == 'true' ]; then
            brew upgrade thefuck
        fi
    elif [[ $platform == "LINUX" ]]; then
        if [ ${force} == 'true' ]; then
            sudo pip3 install thefuck --upgrade --force-reinstall
        else
            sudo pip3 install thefuck
        fi
    fi
}

version_func_thefuck() {
    $1 --version
}

main_script 'thefuck' setup_func_thefuck_local setup_func_thefuck_system version_func_thefuck
