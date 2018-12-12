#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_nodejs_install} == "yes" ]]; then
        [[ ${VERBOSE} == YES ]] || start_spinner "Installing node.js..."
        (
        # curl -sL install-node.now.sh/lts | sed 's/read yn < \/dev\/tty/yn = y/' | sh -s -- --prefix=${HOME}/.local
        curl -sL install-node.now.sh/lts | sh -s -- --prefix=${HOME}/.local --yes
        ) >&3 2>&4 || exit_code="$?" && true
        stop_spinner "${exit_code}" \
            "node.js is installed [local]" \
            "node.js install is failed [local]. use VERBOSE=YES for error message"
    else
        echo "${marker_err} node.js is not installed"
    fi
else
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing node.js..."
    (
    curl -sL install-node.now.sh/lts | sh -s -- --prefix=${HOME}/.local --yes
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "node.js is installed [local]" \
        "node.js install is failed [local]. use VERBOSE=YES for error message"
fi

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
