#!/bin/bash

# change version you want to install on local
ZSH_VERSION=5.6.2


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
        if [ -d $HOME/.local/src/zsh-* ]; then
            cd $HOME/.local/src/zsh-*
            make uninstall
            cd ..
            rm -rf $HOME/.local/src/zsh-*
        fi
        cd $TMP_DIR
        wget http://www.zsh.org/pub/zsh-${ZSH_VERSION}.tar.xz
        tar -xvJf zsh-${ZSH_VERSION}.tar.xz
        cd zsh-${ZSH_VERSION}
        ./configure --prefix=$HOME/.local
        make
        make install
        cd $TMP_DIR
        mv zsh-${ZSH_VERSION} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            # brew install zsh
            brew bundle --file=- <<EOS
brew 'zsh'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get -y install zsh
        else
            echo "[!] $platform is not supported."; exit 1
        fi
        echo "[*] Adding installed zsh to /etc/shells..."
        if grep -Fxq "$(which zsh)" /etc/shells; then
            :
        else
            echo "$(which zsh)" | sudo tee -a /etc/shells
        fi
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi

    echo "[*] zsh installed..."
}


while true; do
    echo
    if [ -x "$(command -v zsh)" ]; then
        echo "[*] Following list is zsh insalled on the system"
        type zsh
    else
        echo "[*] zsh is not found"
    fi
    read -p "[?] Do you wish to install zsh? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install zsh..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install zsh locally..."; setup_func 'local'; break;;
        [Ss]ystem* ) echo "[*] Install zsh systemwide..."; setup_func; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done
