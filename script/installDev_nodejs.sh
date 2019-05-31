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
        if [[ $platform == "OSX" ]]; then
            brew install node || true
            brew install yarn || true
        else
            # curl -sL install-node.now.sh/lts | sed 's/read yn < \/dev\/tty/yn = y/' | sh -s -- --prefix=${HOME}/.local
            if ! command -v node > /dev/null; then
                curl -sL install-node.now.sh/lts | bash -s -- --prefix=${HOME}/.local --yes
            fi
            if ! command -v yarn > /dev/null; then
                curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
            fi
        fi
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
    if [[ $platform == "OSX" ]]; then
        brew install node || true
        brew install yarn || true
    else
        if ! command -v node > /dev/null; then
            curl -sL install-node.now.sh/lts | bash -s -- --prefix=${HOME}/.local --yes
        fi
        if ! command -v yarn > /dev/null; then
            curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
        fi
    fi
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "node.js is installed [local]" \
        "node.js install is failed [local]. use VERBOSE=YES for error message"
fi

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
