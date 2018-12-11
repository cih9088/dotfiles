#!/bin/bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Updating TPM..."
(
rm -rf ${HOME}/.tmux/plugins/tpm || true
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "TPM is updated [local]" \
    "TPM udpate is failed [local]. use VERBOSE=YES for error message"
