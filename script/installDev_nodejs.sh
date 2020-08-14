#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to install Nodejs environment"
################################################################

setup_func_node_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${HOME}/.local/bin/node)" ]; then
        if [ ${force} == 'true' ]; then
            install='true'
        fi
    else
        install='true'
    fi
    if [ ${install} == 'true' ]; then
        curl -sL install-node.now.sh/lts | bash -s -- --prefix=${HOME}/.local --yes
    fi
}

setup_func_node_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        if [ -x "$(command -v /usr/local/bin/node)" ]; then
            if [ ${force} == 'true' ]; then
                brew upgrade node
            fi
        else
            brew install node
        fi
    else
        setup_func_node_local ${force}
    fi

}

setup_func_yarn_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${HOME}/.yarn/bin/yarn)" ]; then
        if [ ${force} == 'true' ]; then
            install='true'
        fi
    else
        install='true'
    fi
    if [ ${install} == 'true' ]; then
        curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
    fi
}

setup_func_yarn_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        if [ -x "$(command -v /usr/local/bin/yarn)" ]; then
            if [ ${force} == 'true' ]; then
                brew upgrade yarn
            fi
        else
            brew install yarn
        fi
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

main_script 'yarn' setup_func_yarn_local setup_func_yarn_system version_func_yarn
