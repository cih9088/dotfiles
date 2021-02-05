#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update tpm${Color_Off}"
################################################################

[[ ${VERBOSE} == "true" ]] \
  && echo "${marker_info} Updating ${Bold}${Underline}TPM${Color_Off}..." \
  || start_spinner "Updating ${Bold}${Underline}TPM${Color_Off}..."
(
rm -rf ${HOME}/.tmux/plugins/tpm || true
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
  "${Bold}${Underline}TPM${Color_Off} is updated [local]" \
  "${Bold}${Underline}TPM${Color_Off} udpate is failed [local]. use VERBOSE=true for error message"
