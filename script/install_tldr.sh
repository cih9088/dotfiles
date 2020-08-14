#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to install tldr"
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
        brew install tldr
    elif [[ $platform == "LINUX" ]]; then
        sudo pip install tldr --upgrade --force-reinstall
    fi
}

version_func_tldr() {
    $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'tldr' setup_func_tldr_local setup_func_tldr_system version_func_tldr
