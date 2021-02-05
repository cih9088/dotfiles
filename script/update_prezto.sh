#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update prezto${Color_Off}"
################################################################

[[ ${VERBOSE} == "true" ]] \
  && echo "${marker_info} Updating ${Bold}${Underline}prezto${Color_Off}..." \
  || start_spinner "Updating ${Bold}${Underline}prezto${Color_Off}..."
(
# update prezto
cd ~/.zprezto
git pull >/dev/null
git submodule update --init --recursive

# update pure prompt
cd ${HOME}/.zprezto/modules/prompt/external/pure
git checkout main
git pull
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
  "${Bold}${Underline}prezto${Color_Off} is updated [local]" \
  "${Bold}${Underline}prezto${Color_Off} udpate is failed [local]. use VERBOSE=true for error message"
