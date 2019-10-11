#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

TARGET='pyenv'

setup_func_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${HOME}/.pyenv/bin/pyenv)" ]; then
        if [ ${force} == 'yes' ]; then
            rm -rf ${HOME}/.pyenv || true
            install=yes
        fi
    else
        install=yes
    fi

    if [ ${install} == yes ]; then
        curl https://pyenv.run | bash
        git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install pyenv
        brew install pyenv-virtualenv
        brew install pyenv-virtualenvwrapper
    else
        curl https://pyenv.run | bash
        git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper
    fi

}

version_func() {
    $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script ${TARGET} setup_func_local setup_func_system version_func
