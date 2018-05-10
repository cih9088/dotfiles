#!/bin/bash

# change version you want to install on local
ZSH_VERSION=5.5.1


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
        if [ -d $HOME/.local/src/zsh-* ]; then
            cd $HOME/.local/src/zsh-*
            make uninstall
            cd ..
            rm -rf $HOME/.local/src/zsh-*
        fi
        cd $TMP_DIR
        wget http://www.zsh.org/pub/zsh-${ZSH_VERSION}.tar.gz
        tar -xvzf zsh-${ZSH_VERSION}.tar.gz
        cd zsh-${ZSH_VERSION}
        ./configure --prefix=$HOME/.local
        make
        make install
        cd $TMP_DIR
        mv zsh-${ZSH_VERSION} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            brew install zsh
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get install zsh
        else
            echo 'not defined'; exit 1
        fi
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi

    echo "[*] zsh installed..."
}


while true; do
    read -p "\nDo you wish to install zsh ($1)? " yn
    case $yn in
        [Yy]* ) echo "[*] installing zsh..."; setup_func; break;;
        [Nn]* ) echo "[!] aborting install zsh..."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
