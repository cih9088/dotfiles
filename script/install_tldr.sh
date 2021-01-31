#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install tldr${Color_Off}"

TEALDEER_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release dbrgn/tealdeer)"
TEALDEER_VERSION=${1:-${TEALDEER_LATEST_VERSION##v}}
[[ ${TEALDEER_VERSION} != "v"* ]] && TEALDEER_VERSION="v${TEALDEER_VERSION}"
$(${PROJ_HOME}/script/check_release dbrgn/tealdeer ${TEALDEER_VERSION}) || exit $?
################################################################

setup_func_tldr_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -f ${HOME}/.local/bin/tldr ]; then
        if [ ${force} == 'true' ]; then
            rm -rf $HOME/.local/bin/tldr || true
            install=true
        fi
    else
        install=true
    fi

    # uninstall slow tldr client
    pip uninstall tldr || true

    wget https://github.com/dbrgn/tealdeer/releases/download/${TEALDEER_VERSION}/tldr-linux-x86_64-musl
    mv tldr-linux-x86_64-musl ${HOME}/.local/bin/tldr
    chmod +x ${HOME}/.local/bin/tldr
    ${HOME}/.local/bin/tldr --update
}

setup_func_tldr_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        # uninstall slow tldr client
        brew list tldr && brew uninstall tldr
        brew list tealdeer || brew install tealdeer
        if [ ${force} == 'true' ]; then
            brew upgrade tealdeer
        fi
        $(brew --prefix)/bin/tldr --update
    elif [[ $platform == "LINUX" ]]; then
        setup_func_tldr_local ${force}
    fi
}

main_script 'tldr' setup_func_tldr_local setup_func_tldr_system
