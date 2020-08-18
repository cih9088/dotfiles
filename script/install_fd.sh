#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install fd${Color_Off}"

FD_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release sharkdp/fd)"
FD_VERSION=${1:-${FD_LATEST_VERSION##v}}
[[ ${FD_VERSION} != "v"* ]] && FD_VERSION="v${FD_VERSION}"
$(${PROJ_HOME}/script/check_release sharkdp/fd ${FD_VERSION}) || exit $?
################################################################

setup_func_fd_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -f ${HOME}/.local/bin/fd ]; then
        if [ ${force} == 'true' ]; then
            rm -rf $HOME/.local/bin/fd || true
            rm -rf $HOME/.local/man/man1/fd.1 || true
            install=true
        fi
    else
        install=true
    fi

    if [ ${install} == 'true' ]; then
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-x86_64-apple-darwin.tar.gz
            tar -xvzf fd-${FD_VERSION}-x86_64-apple-darwin.tar.gz
            cd fd-${FD_VERSION}-x86_64-apple-darwin
            yes | \cp -rf fd $HOME/.local/bin
            yes | \cp -rf fd.1 $HOME/.local/man/man1
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            tar -xvzf fd-${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            cd fd-${FD_VERSION}-x86_64-unknown-linux-gnu
            yes | \cp -rf fd $HOME/.local/bin
            yes | \cp -rf fd.1 $HOME/.local/man/man1
        fi
    fi
}

setup_func_fd_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew list fd || brew install fd
        if [ ${force} == 'true' ]; then
            brew upgrade fd
        fi
    elif [[ $platform == "LINUX" ]]; then
        cd $TMP_DIR
        wget https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd_${FD_VERSION##v}_amd64.deb
        sudo dpkg -i fd_${FD_VERSION##v}_amd64.deb
    fi
}

version_func_fd() {
    $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'fd' setup_func_fd_local setup_func_fd_system version_func_fd
