#!/bin/bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_info} Coyping custom bin files..."

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
fi

echo "${marker_ok} custom bin files copied"

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
