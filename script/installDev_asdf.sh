#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install asdf${Color_Off}"
################################################################

setup_func_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
        if [ ${force} == 'true' ]; then
            install='true'
        fi
    else
        install='true'
    fi

    if [ ${install} == 'true' ]; then
        if [ -d ${HOME}/.asdf ]; then
            . $HOME/.asdf/asdf.sh
            asdf update
        else
            git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf
            cd ${HOME}/.asdf
            git checkout "$(git describe --abbrev=0 --tags)"
        fi
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew list asdf || brew install asdf
        if [ ${force} == 'true' ]; then
            brew upgrade asdf
        fi
    else
        setup_func_local ${force}
    fi
}

version_func() {
    $1 version
}

main_script 'asdf' setup_func_local setup_func_system version_func
