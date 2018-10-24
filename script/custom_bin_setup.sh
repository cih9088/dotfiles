#!/bin/bash

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
BIN_DIR=${PROJ_HOME}/bin

echo
echo '[*] Coyping custom bin files...'

# https://github.com/ChristopherSchultz/fast-file-count
cd $BIN_DIR; cc -Wall -pedantic -o dircnt dircnt.c;

if [[ $platform == "OSX" ]]; then
    for file in `find ${BIN_DIR} -type f -perm +111 -exec basename {} \;`; do
        ln -snf ${BIN_DIR}/${file} $HOME/.local/bin/$file
    done
elif [[ $platform == "LINUX" ]]; then
    for file in `find ${BIN_DIR} -type f -executable -printf "%f\n"`; do
        ln -snf ${BIN_DIR}/${file} $HOME/.local/bin/$file
    done
else
    echo "[!] $platform is not supported."; exit 1
fi


# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
