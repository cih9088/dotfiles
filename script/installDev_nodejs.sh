#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################


setup_func_node_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${HOME}/.local/bin/node)" ]; then
        if [ ${force} == 'yes' ]; then
            install=yes
        fi
    else
        install=yes
    fi
    if [ ${install} == yes ]; then
        curl -sL install-node.now.sh/lts | bash -s -- --prefix=${HOME}/.local --yes
    fi
}

setup_func_node_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install node
    else
        setup_func_node_local ${force}
    fi

}

setup_func_yarn_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${HOME}/.yarn/bin/yarn)" ]; then
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

setup_func_yarn_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install yarn
    else
        setup_func_yarn_local ${force}
    fi

}

version_func_node() {
    $1 --version
}

version_func_yarn() {
    $1 --version
}

main_script 'node' setup_func_node_local setup_func_node_system version_func_node

main_script 'yarn' setup_func_yarn_local setup_func_yarn_system version_func version_func_yarn
