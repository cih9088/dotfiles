#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare to ${BOLD}${UNDERLINE}update ${THIS}${NC}"
################################################################

[[ ${VERBOSE} == "true" ]] &&
  log_info "Updating ${THIS_HL}..." ||
  start_spinner "Updating ${THIS_HL}..."
(
# https://github.com/ChristopherSchultz/fast-file-count
cd $BIN_DIR; cc -Wall -pedantic -o dircnt dircnt.c;

if [[ ${PLATFORM} == "OSX" ]]; then
  for file in `find ${BIN_DIR} -type f -perm +111 -exec basename {} \;`; do
    log_info "Update symbolic link '${BIN_DIR}/${file}' -> '$HOME/.local/bin/$file'"
    ln -snf ${BIN_DIR}/${file} $HOME/.local/bin/$file
  done
elif [[ ${PLATFORM} == "LINUX" ]]; then
  for file in `find ${BIN_DIR} -type f -executable -printf "%f\n"`; do
    log_info "Update symbolic link '${BIN_DIR}/${file}' -> '$HOME/.local/bin/$file'"
    ln -snf ${BIN_DIR}/${file} $HOME/.local/bin/$file
  done
fi
) >&3 2>&4 && exit_code="0" || exit_code="$?"
stop_spinner "${exit_code}" \
  "${THIS_HL} is updated [local]" \
  "${THIS_HL} update is failed [local]. use VERBOSE=true for error message"
