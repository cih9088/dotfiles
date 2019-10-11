#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

TARGET='nvim'
NVIM_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release neovim/neovim)"
NVIM_VERSION=${1:-${NVIM_LATEST_VERSION}}
if [[ ${NVIM_VERSION} != 'nightly' ]] && [[ ${NVIM_VERSION} != "v"* ]]; then
    NVIM_VERSION="v${NVIM_VERSION}"
fi

XCLIP_VERSION=0.12

################################################################

setup_func_python_support() {
    neovim3_version='3.7.2'
    neovim3_virenv='neovim3'
    neovim2_version='2.7.16'
    neovim2_virenv='neovim2'

    export WORKON_HOME=${HOME}/.virtualenvs
    mkdir -p ${WORKON_HOME}

    rm -rf ${WORKON_HOME}/${neovim2_virenv} || true
    rm -rf ${WORKON_HOME}/${neovim3_virenv} || true

    if ! command -v ${HOME}/.pyenv/bin/pyenv > /dev/null; then
        if [[ $1 == local ]]; then
            curl https://pyenv.run | bash
            git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper
        else
            if [[ $platform == "OSX" ]]; then
                brew install pyenv
                brew install pyenv-virtualenv
                brew install pyenv-virtualenvwrapper
            elif [[ $platform == "LINUX" ]]; then
                curl https://pyenv.run | bash
                git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper
            fi
        fi
    fi

    ${HOME}/.pyenv/bin/pyenv install -s ${neovim3_version}
    ${HOME}/.pyenv/bin/pyenv install -s ${neovim2_version}

    virtualenv --python=${HOME}/.pyenv/versions/${neovim2_version}/bin/python ${WORKON_HOME}/${neovim2_virenv}
    source ${WORKON_HOME}/${neovim2_virenv}/bin/activate
    pip install neovim

    virtualenv --python=${HOME}/.pyenv/versions/${neovim3_version}/bin/python ${WORKON_HOME}/${neovim3_virenv}
    source ${WORKON_HOME}/${neovim3_virenv}/bin/activate
    pip install neovim

}

setup_func_local() {
    force=$1
    cd $TMP_DIR

    # verify given version is valid version
    curl -s --head https://github.com/neovim/neovim/releases/tag/${NVIM_VERSION} \
        | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
    if [[ $? != 0 ]]; then
        printf "\033[2K\033[${ctr}D${IRed}[!]${Color_Off}" >&2
        printf " ${NVIM_VERSION} is not a valid version\n" >&2
        printf "\033[2K\033[${ctr}D${IRed}[!]${Color_Off}" >&2
        printf " please visit https://github.com/neovim/neovim/tags for valid versions\n" >&2
        exit 1
    fi

    install=no
    if [ -f ${HOME}/.local/bin/nvim ]; then
        if [ ${force} == 'yes' ]; then
            rm -rf ${HOME}/.local/bin/nvim || true
            rm -rf ${HOME}/.local/man/man1/nvim.1 || true
            rm -rf ${HOME}/.local/share/nvim/runtim || true
            install=yes
        fi
    else
        install=yes
    fi

    if [ ${install} == 'yes' ]; then
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
            tar -xvzf nvim-macos.tar.gz
            yes | \cp -rf nvim-osx64/* $HOME/.local/
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
            # https://github.com/neovim/neovim/issues/7620
            # https://github.com/neovim/neovim/issues/7537
            chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract
            yes | \cp -rf squashfs-root/usr/bin $HOME/.local
            yes | \cp -rf squashfs-root/usr/man $HOME/.local
            yes | \cp -rf squashfs-root/usr/share/nvim $HOME/.local/share
            # yes | \cp -rf squashfs-root/usr/* $HOME/.local
            # chmod u+x nvim.appimage && mv nvim.appimage nvim
            # cp nvim $HOME/.local/bin
        fi
        setup_func_python_support
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install neovim
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get install software-properties-common
        sudo add-apt-repository ppa:neovim-ppa/stable
        sudo apt-get update
        sudo apt-get install neovim
    fi

    setup_func_python_support
}

version_func() {
     $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script ${TARGET} setup_func_local setup_func_system version_func
