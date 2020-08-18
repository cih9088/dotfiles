#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update tmux plugin${Color_Off}"
################################################################

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating ${Bold}${Underline}tmux plugins${Color_Off}..." \
    || start_spinner "Updating ${Bold}${Underline}tmux plugins${Color_Off}..."
(
${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh
${HOME}/.tmux/plugins/tpm/scripts/update_plugin.sh "" all
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "${Bold}${Underline}tmux plugins${Color_Off} are updated [local]" \
    "${Bold}${Underline}tmux plugins${Color_Off} udpate is failed [local]. use VERBOSE=true for error message"
