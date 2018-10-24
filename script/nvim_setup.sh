#!/bin/bash

NVIM_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/neovim/neovim/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')
NVIM_LATEST_VERSION=${NVIM_LATEST_VERSION##v}
NVIM_VERSION=${1:-${NVIM_LATEST_VERSION}}

################################################################
set -e

case "$OSTYPE" in
    solaris*) platform="SOLARIS" ;;
    darwin*)  platform="OSX" ;;
    linux*)   platform="LINUX" ;;
    bsd*)     platform="BSD" ;;
    msys*)    platform="WINDOWS" ;;
    *)        platform="unknown: $OSTYPE" ;;
esac

if [[ $$ = $BASHPID ]]; then
    PROJ_HOME=$(git rev-parse --show-toplevel)
    TMP_DIR=$HOME/tmp_install

    if [ ! -d $HOME/.local/bin ]; then
        mkdir -p $HOME/.local/bin
    fi

    if [ ! -d $HOME/.local/src ]; then
        mkdir -p $HOME/.local/src
    fi

    if [ ! -d $TMP_DIR ]; then
        mkdir -p $TMP_DIR
    fi
fi

setup_func() {
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
            chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract
            cp -r squashfs-root/usr/bin $HOME/.local
            cp -r squashfs-root/usr/man $HOME/.local
            cp -r squashfs-root/usr/share/nvim $HOME/.local/share
            # chmod u+x nvim.appimage && mv nvim.appimage nvim
            # cp nvim &HOME/.local/bin
        else
            echo "[!] $platform is not supported."; exit 1
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
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi

    echo "[*] neovim installed..."

    # install neovim with python support
    echo
    echo '[*] Install neovim with python support'
    sleep 1

    if [[ $1 = local ]]; then
        pip install --no-cache-dir --upgrade --force-reinstall --user neovim || true
        pip2 install --no-cache-dir --upgrade --force-reinstall --user neovim || true
        pip3 install --no-cache-dir --upgrade --force-reinstall --user neovim || true
    else
        pip install --no-cache-dir --upgrade --force-reinstall neovim || true
        pip2 install --no-cache-dir --upgrade --force-reinstall neovim || true
        pip3 install --no-cache-dir --upgrade --force-reinstall neovim || true
    fi
}


while true; do
    echo
    if [ -x "$(command -v nvim)" ]; then
        echo "[*] Following list is nvim insalled on the system"
        type nvim
        echo
        echo "[*] Your nvim version is...."
        nvim --version
    else
        echo "[*] nvim is not found"
    fi

    echo "[*] Local install version (latest version: $NVIM_LATEST_VERSION, installing version: $NVIM_VERSION)"
    read -p "[?] Do you wish to install neovim? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install neovim..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install neovim locally..."; setup_func 'local'; break;;
        [Ss]ystem* ) echo "[*] Install neovim systemwide..."; setup_func; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done
