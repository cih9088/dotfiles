#!/bin/bash

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


setup_func_shellcheck() {
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            echo "[!] Not available on OSX"
            exit 1
        elif [[ $platform == "LINUX" ]]; then
            wget https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz
            tar -xvJf shellcheck-stable.linux.x86_64_tar.xz
            cd shellcheck-stable
            cp shellcheck $HOME/.local/bin
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    else
        if [[ $platform == "OSX" ]]; then
            # brew install shellcheck
            brew bundle --file=- <<EOS
brew 'shellcheck'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get install shellcheck
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] shellcheck command installed..."

}

while true; do
    echo
    read -p "[?] Do you wish to install shellcheck? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install shellcheck..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or systemwide? " yn
    case $yn in
        [Ll]local* ) echo "[*] Install shellcheck locally..."; setup_func_shellcheck 'local'; break;;
        [Ss]ystem* ) echo "[*] Install shellcheck systemwide..."; setup_func_shellcheck; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done
