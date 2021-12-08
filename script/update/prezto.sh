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
# update prezto
cd ~/.zprezto
git pull
git submodule update --init --recursive

# update pure prompt
cd ${HOME}/.zprezto/modules/prompt/external/pure
git checkout main
git pull
) >&3 2>&4 && exit_code="0" || exit_code="$?"
stop_spinner "${exit_code}" \
  "${THIS_HL} is updated [local]" \
  "${THIS_HL} udpate is failed [local]. use VERBOSE=true for error message"
