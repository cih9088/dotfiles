#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

TARGET='nodejs'

setup_func_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v node)" ]; then
        if [ ${force} == 'yes' ]; then
            install=yes
        fi
    else
        install=yes
    fi
    if [ ${install} == yes ]; then
        curl -sL install-node.now.sh/lts | bash -s -- --prefix=${HOME}/.local --yes
    fi

    install=no
    if [ -x "$(command -v yarn)" ]; then
        if [ ${force} == 'yes' ]; then
            install=yes
        fi
    else
        install=yes
    fi
    if [ ${install} == yes ]; then
        curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install node
        brew install yarn
    else
        setup_func_local ${force}
    fi

}

main_script ${TARGET} setup_func_local setup_func_system
