#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install bpytop${Color_Off}"

# if asdf is installed
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
export PATH="${HOME}/.pyenv/bin:$PATH"
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true

################################################################

setup_func_bpytop_local() {
    force=$1
    cd $TMP_DIR

    if [ ${force} == 'true' ]; then
        pip3 install bpytop --user --force-reinstall --upgrade
    else
        pip3 install bpytop --user
    fi
}

setup_func_bpytop_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        if [ ${force} == 'true' ]; then
            pip3 install bpytop --upgrade --force-reinstall
        else
            pip3 install bpytop
        fi
    elif [[ $platform == "LINUX" ]]; then
        if [ ${force} == 'true' ]; then
            sudo pip3 install bpytop --upgrade --force-reinstall
        else
            sudo pip3 install bpytop
        fi
    fi
}

version_func_bpytop() {
    $1 --version 2>&1
}

main_script 'bpytop' setup_func_bpytop_local setup_func_bpytop_system version_func_bpytop
