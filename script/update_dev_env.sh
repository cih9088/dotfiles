#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update dev env${Color_Off}"

export PATH="${HOME}/.pyenv/bin:$PATH"
export PATH="${HOME}/.goenv/bin:$PATH"
export PATH="${HOME}/.local/bin:$PATH"

# if asdf is installed
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true
command -v goenv > /dev/null && eval "$(goenv init -)" || true
################################################################

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating ${Bold}${Underline}dev env${Color_Off}..." \
    || start_spinner "Updating ${Bold}${Underline}dev env${Color_Off}..."
(

command -v asdf > /dev/null && for plugin in $(asdf plugin list); do asdf reshim $plugin; done || true
command -v pyenv > /dev/null && pyenv reshim || true
command -v goenv > /dev/null && goenv reshim || true

) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "${Bold}${Underline}dev env${Color_Off} are updated [local]" \
    "${Bold}${Underline}dev env${Color_Off} udpate is failed [local]. use VERBOSE=true for error message"
