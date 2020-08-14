#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to update bin directory"
################################################################

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating custom bin files..." \
    || start_spinner "Updating custom bin files..."
(
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
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "custom bin files are updated [local]" \
    "custom bin files update is failed [local]. use VERBOSE=true for error message"

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
