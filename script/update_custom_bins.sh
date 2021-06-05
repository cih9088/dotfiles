#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update bin directory${Color_Off}"
################################################################

[[ ${VERBOSE} == "true" ]] &&
  echo "${marker_info} Updating ${Bold}${Underline}custom bin files${Color_Off}..." ||
  start_spinner "Updating ${Bold}${Underline}custom bin files${Color_Off}..."
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
  "${Bold}${Underline}custom bin files${Color_Off} are updated [local]" \
  "${Bold}${Underline}custom bin files${Color_Off} update is failed [local]. use VERBOSE=true for error message"

# clean up
if [[ $$ = $BASHPID ]]; then
  rm -rf $TMP_DIR
fi
