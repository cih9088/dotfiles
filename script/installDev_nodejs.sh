#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_info} Install node.js"
if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_nodejs_install} == "yes" ]]; then
        (
        # curl -sL install-node.now.sh/lts | sed 's/read yn < \/dev\/tty/yn = y/' | sh -s -- --prefix=${HOME}/.local
        curl -sL install-node.now.sh/lts | sh -s -- --prefix=${HOME}/.local --yes
        ) >&3 2>&4 \
            && echo -e "\033[2K \033[100D${marker_ok} node.js is installed [$1]" \
            || echo -e "\033[2K \033[100D${marker_err} node.js install is failed [$1]. use VERBOSE=YES for error message" &
        [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing node.js..."
    else
        echo "${marker_err} node.js is not installed"
    fi
else
    curl -sL install-node.now.sh/lts | sh -s -- --prefix=${HOME}/.local
    echo "${marker_ok} node.js installed [local]"
fi

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
