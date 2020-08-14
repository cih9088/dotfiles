#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to install nvim"

NVIM_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release neovim/neovim)"
NVIM_VERSION=${1:-${NVIM_LATEST_VERSION##v}}
if [[ ${NVIM_VERSION} != 'nightly' ]] && [[ ${NVIM_VERSION} != "v"* ]]; then
    NVIM_VERSION="v${NVIM_VERSION}"
fi
$(${PROJ_HOME}/script/check_release neovim/neovim ${NVIM_VERSION}) || exit $?

# use sytem python
export VIRTUALENVWRAPPER_PYTHON=$(which python)
export VIRTUALENVWRAPPER_VIRTUALENV=$(which virtualenv)
export VIRTUALENVWRAPPER_SCRIPT=$(which virtualenvwrapper.sh)
export VIRTUALENVWRAPPER_LAZY_SCRIPT=$(which virtualenvwrapper_lazy.sh)
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
export PYENV_ROOT=${HOME}/.pyenv

export PATH="${HOME}/.pyenv/bin:$PATH"
export WORKON_HOME=${HOME}/.virtualenvs

neovim3_virenv='neovim3'
neovim2_virenv='neovim2'
################################################################

setup_func_python_support() {
    if ! command -v pyenv > /dev/null; then
        echo "${marker_err} pyenv is not found" >&2
        echo "${marker_err} Please run 'make installDevPython' first, then 'make installNeovim'" >&2
        exit 1
    fi
    eval "$(pyenv init -)"

    install=no
    if [ $(find ${HOME}/.pyenv/versions -name ${neovim3_virenv} -depth 1 | wc -l) -ge 1 ]; then
        if [ ${force} == 'true' ]; then
            pyenv virtualenv-delete -f ${neovim3_virenv}
            install=true
        fi
    else
        install=true
    fi

    if [ ${install} == 'true' ]; then
        pyenv_py3_version=$(pyenv versions --bare  | grep '^[0-9.]\+$'  | grep '^3.*' | sort -rV | head)
        if [ -z ${pyenv_py3_version} ]; then
            pyenv latest install -s 3
            pyenv_py3_version=$(pyenv versions --bare  | grep '^[0-9.]\+$'  | grep '^3.*' | sort -rV | head)
        fi
        pyenv virtualenv ${pyenv_py3_version} ${neovim3_virenv}
        pyenv shell ${neovim3_virenv}
        pip install neovim
    fi

    install=no
    if [ $(find ${HOME}/.pyenv/versions -name ${neovim2_virenv} -depth 1 | wc -l) -ge 1 ]; then
        if [ ${force} == 'true' ]; then
            pyenv virtualenv-delete -f ${neovim2_virenv}
            install=true
        fi
    else
        install=true
    fi

    if [ ${install} == 'true' ]; then
        pyenv_py2_version=$(pyenv versions --bare  | grep '^[0-9.]\+$'  | grep '^2.*' | sort -rV | head)
        if [ -z ${pyenv_py2_version} ]; then
            pyenv latest install -s 2
            pyenv_py2_version=$(pyenv versions --bare  | grep '^[0-9.]\+$'  | grep '^2.*' | sort -rV | head)
        fi
        pyenv virtualenv ${pyenv_py2_version} ${neovim2_virenv}
        pyenv shell ${neovim2_virenv}
        pip install neovim
    fi
}

setup_func_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${HOME}/.local/bin/nvim)" ]; then
        if [ ${force} == 'true' ]; then
            rm -rf ${HOME}/.local/bin/nvim || true
            rm -rf ${HOME}/.local/man/man1/nvim.1 || true
            rm -rf ${HOME}/.local/share/nvim/runtim || true
            install=true
        fi
    else
        install=true
    fi

    if [ ${install} == 'true' ]; then
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
        setup_func_python_support ${force}
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        if [ -x "$(command -v /usr/local/bin/nvim)" ]; then
            if [ ${force} == 'true' ]; then
                brew upgrade neovim
            fi
        else
            brew install neovim
        fi
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get install software-properties-common
        sudo add-apt-repository ppa:neovim-ppa/stable
        sudo apt-get update
        sudo apt-get install neovim
    fi
    setup_func_python_support ${force}
}

version_func() {
     $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'nvim' setup_func_local setup_func_system version_func
