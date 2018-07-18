#!/bin/bash

# change version you want to install on local
TREE_VERSION=1.7.0
FD_VERSION=7.0.0
RG_VERSION=0.8.1

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

BIN_DIR=${PROJ_HOME}/bin


# https://github.com/ChristopherSchultz/fast-file-count
cd $BIN_DIR; cc -Wall -pedantic -o dircnt dircnt.c;

# tree
setup_func_tree() {
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        wget http://mama.indstate.edu/users/ice/tree/src/tree-${TREE_VERSION}.tgz
        tar -xvzf tree-${TREE_VERSION}.tgz
        cd tree-${TREE_VERSION}
        sed -i -e "s|prefix = /usr|prefix = $HOME/.local|" Makefile
        make
        make install
        cd $TMP_DIR
        rm -rf $HOME/.local/src/tree-*
        mv tree-${TREE_VERSION} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            brew install tree
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get -y install tree
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] tree command installed..."
}

# fd
setup_func_fd() {
    if [[ $1 = local ]]; then
        echo $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-apple-darwin.tar.gz
            tar -xvzf fd-v${FD_VERSION}-x86_64-apple-darwin.tar.gz
            cd fd-v${FD_VERSION}-x86_64-apple-darwin
            cp fd $HOME/.local/bin
            cp fd.1 $HOME/.local/man/man1
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            tar -xvzf fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            cd fd-v${FD_VERSION}-x86_64-unknown-linux-gnu
            cp fd $HOME/.local/bin
            cp fd.1 $HOME/.local/man/man1
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    else
        if [[ $platform == "OSX" ]]; then
            brew install fd
        elif [[ $platform == "LINUX" ]]; then
            cd $TMP_DIR
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb
            sudo dpkg -i fd_${FD_VERSION}_amd64.deb
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] fd command installed..."
}

# thefuck
setup_func_thefuck() {
    if [[ $1 = local ]]; then
        pip3 install thefuck --user
    else
        if [[ $platform == "OSX" ]]; then
            brew install thefuck
        elif [[ $platform == "LINUX" ]]; then
            sudo pip3 install thefuck
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] thefuck command installed..."
}

# rg
setup_func_rg() {
    if [[ $1 = local ]]; then
        echo $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
            tar -xvzf ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
            cd ripgrep-${RG_VERSION}-x86_64-apple-darwin
            cp rg $HOME/.local/bin
            cp doc/rg.1 $HOME/.local/man/man1
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
            tar -xvzf ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
            cd ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl
            cp rg $HOME/.local/bin
            cp doc/rg.1 $HOME/.local/man/man1
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    else
        if [[ $platform == "OSX" ]]; then
            brew install ripgrep
        elif [[ $platform == "LINUX" ]]; then
            cd $TMP_DIR
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
            sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] rg command installed..."
}

setup_func_ranger() {
    rm -rf $HOME/.local/src/ranger
    git clone https://github.com/cih9088/ranger $HOME/.local/src/ranger
    $HOME/.local/src/ranger/ranger.py --copy-config=all
    ln -sf $HOME/.local/src/ranger/ranger.py $HOME/.local/bin/ranger
}

while true; do
    echo
    read -p "[?] Do you wish to install tree? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install tree..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install tree locally..."; setup_func_tree 'local'; break;;
        [Ss]ystem* ) echo "[*] Install tree systemwide..."; setup_func_tree; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    read -p "[?] Do you wish to install fd? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install fd..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install fd locally..."; setup_func_fd 'local'; break;;
        [Ss]ystem* ) echo "[*] Install fd systemwide..."; setup_func_fd; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    read -p "[?] Do you wish to install ripgrep? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install ripgrep..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install ripgrep locally..."; setup_func_rg 'local'; break;;
        [Ss]ystem* ) echo "[*] Install ripgrep systemwide..."; setup_func_rg; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    read -p "[?] Do you wish to install ranger? (it will be installed on local) " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install ranger..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    setup_func_ranger
    break
done


while true; do
    echo
    read -p "[?] Do you wish to install thefuck? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install thefuck..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install thefuck locally..."; setup_func_thefuck 'local'; break;;
        [Ss]ystem* ) echo "[*] Install thefuck systemwide..."; setup_func_thefuck; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    read -p "[?] Do you wish to install tldr? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install tldr..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install tldr locally..."; pip install tldr --user; break;;
        [Ss]ystem* ) echo "[*] Install tldr systemwide..."; sudo pip install tldr; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done




echo '[*] Coyping bin files...'
for file in `find ${BIN_DIR} -type f -executable -printf "%f\n"`; do
    cp -rf ${BIN_DIR}/$file $HOME/.local/bin/$file
done

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
