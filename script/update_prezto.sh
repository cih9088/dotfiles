#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to update prezto"
################################################################

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating prezto..." \
    || start_spinner "Updating prezto..."
(
# update prezto
cd ~/.zprezto
git pull >/dev/null
git submodule update --init --recursive

# update pure prompt
cd ${HOME}/.zprezto/modules/prompt/external/pure
git checkout master
git pull
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "prezto is updated [local]" \
    "prezto udpate is failed [local]. use VERBOSE=true for error message"
