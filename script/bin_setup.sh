#!/bin/bash

# change version you want to install on local
TREE_VERSION=1.7.0
FD_VERSION=7.0.0

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
        mv tree-${TREE_VERSIOn} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            brew install tree
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get install tree
        else
            echo 'not defined'; exit 1
        fi
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi

    echo "[*] tree command installed..."
}

# fd
setup_func_fd() {
    if [[ $1 = local ]]; then
        echo '[!] not available!'
    else
        if [[ $platform == "OSX" ]]; then
            brew install fd
        elif [[ $platform == "LINUX" ]]; then
            cd $TMP_DIR
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb
            sudo dpkg -i fd_${FD_VERSION}_amd64.deb
        else
            echo 'not defined'; exit 1
        fi
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi

    echo "[*] fd command installed..."
}


while true; do
    read -p "\nDo you wish to install tree ($1)? " yn
    case $yn in
        [Yy]* ) echo "[*] installing tree..."; setup_func_tree; break;;
        [Nn]* ) echo "[!] aborting install tree..."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done


while true; do
    read -p "\nDo you wish to install fd ($1)? " yn
    case $yn in
        [Yy]* ) echo "[*] installing fd..."; setup_func_fd; break;;
        [Nn]* ) echo "[!] aborting install fd..."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

for file in `find ${BIN_DIR} -type f -executable -printf "%f\n"`; do
    ln -s ${BIN_DIR}/$file ~/.local/bin/$file
done

# clean up
rm -rf $TMP_DIR
