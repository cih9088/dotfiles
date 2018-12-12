#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Updating prezto..."
(
cd ~/.zprezto
git pull >/dev/null
git submodule update --init --recursive
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "prezto is updated [local]" \
    "prezto udpate is failed [local]. use VERBOSE=YES for error message"
