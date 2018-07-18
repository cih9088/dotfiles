#!/bin/bash

# change version you want to install on local
NVIM_VERSION=0.3.0


################################################################
set -e

case "$OSTYPE" in
    solaris*) platform='SOLARIS' ;;
    darwin*)  platform='OSX' ;;
    linux*)   platform='LINUX' ;;
    bsd*)     platform='BSD' ;;
    msys*)    platform='WINDOWS' ;;
    *)        platform='unknown: $OSTYPE' ;;
esac

if [[ $$ = $BASHPID ]]; then
    if [[ $platform == "OSX" ]]; then
        PROJ_HOME=$(cd $(echo $(dirname $0) | xargs greadlink -f ); cd ..; pwd)
    elif [[ $platform == "LINUX" ]]; then
        PROJ_HOME=$(cd $(echo $(dirname $0) | xargs readlink -f ); cd ..; pwd)
    fi
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
            brew install neovim
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
}


while true; do
    echo
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
