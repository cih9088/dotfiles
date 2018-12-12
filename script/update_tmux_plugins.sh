#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Updating tmux plugins..."
(
${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh
${HOME}/.tmux/plugins/tpm/scripts/update_plugin.sh "" all
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "tmux plugins are updated [local]" \
    "tmux plugins udpate is failed [local]. use VERBOSE=YES for error message"
