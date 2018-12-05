#!/bin/bash

NVIM_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/neovim/neovim/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')
NVIM_LATEST_VERSION=${NVIM_LATEST_VERSION##v}
NVIM_VERSION=${1:-${NVIM_LATEST_VERSION}}

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

setup_func() {
    (
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-macos.tar.gz
            tar -xvzf nvim-macos.tar.gz
            cp -r nvim-osx64/* $HOME/.local/
        elif [[ $platform == "LINUX" ]]; then
            # https://github.com/neovim/neovim/issues/7620
            # https://github.com/neovim/neovim/issues/7537
            wget https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim.appimage
            # chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract
            # cp -r squashfs-root/usr/bin $HOME/.local
            # cp -r squashfs-root/usr/man $HOME/.local
            # cp -r squashfs-root/usr/share/nvim $HOME/.local/share
            chmod u+x nvim.appimage && mv nvim.appimage nvim
            cp nvim $HOME/.local/bin
        fi
    else
        if [[ $platform == "OSX" ]]; then
            # brew install neovim
            brew bundle --file=- <<EOS
brew 'neovim'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get install software-properties-common
            sudo add-apt-repository ppa:neovim-ppa/stable
            sudo apt-get update
            sudo apt-get install neovim
        fi
    fi
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing neovim..."
    echo "${marker_ok} neovim installed"

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}


main() {
    echo
    if [ -x "$(command -v nvim)" ]; then
        echo "${marker_info} Following list is nvim installed on the system"
        coms=($(which -a nvim | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} --version | head -1)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} nvim is not found"
    fi

    while true; do
        echo "${marker_info} Local install version (latest version: $NVIM_LATEST_VERSION, installing version: $NVIM_VERSION)"
        read -p "${marker_que} Do you wish to install neovim? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install neovim"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Install locally or sytemwide? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_info} Install neovim ${NVIM_VERSION} locally"; setup_func 'local'; break;;
            [Ss]ystem* ) echo "${marker_info} Install latest neovim systemwide"; setup_func; break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done

    # install neovim with python support
    (
    pip install virtualenv --user
    pip install virtualenvwrapper --user
    pip3 install virtualenv --user
    pip3 install virtualenvwrapper --user

    rm -rf ${HOME}/.virtualenvs/neovim2 || true
    rm -rf ${HOME}/.virtualenvs/neovim3 || true

    if [[ $platform == "OSX" ]]; then
        source ${HOME}/Library/Python/3.7/bin/virtualenvwrapper.sh
    elif [[ $platform == "LINUX" ]]; then
        source ${HOME}/.local/bin/virtualenvwrapper.sh
    fi

    VIRENV_NAME=neovim2
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=$(which python2)
    mkvirtualenv -p `which python2` ${VIRENV_NAME} || true
    pip install neovim

    VIRENV_NAME=neovim3
    export VIRTUALENVWRAPPER_PYTHON=$(which python3)
    mkvirtualenv -p `which python3` ${VIRENV_NAME} || true
    pip install neovim

    # if [[ $1 = local ]]; then
    #     pip install --no-cache-dir --upgrade --force-reinstall --user neovim || true
    #     pip2 install --no-cache-dir --upgrade --force-reinstall --user neovim || true
    #     pip3 install --no-cache-dir --upgrade --force-reinstall --user neovim || true
    # else
    #     pip install --no-cache-dir --upgrade --force-reinstall neovim || true
    #     pip2 install --no-cache-dir --upgrade --force-reinstall neovim || true
    #     pip3 install --no-cache-dir --upgrade --force-reinstall neovim || true
    # fi
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing neovim with python support..."
    echo "${marker_ok} neovim with python support installed"

}

main "$@"
