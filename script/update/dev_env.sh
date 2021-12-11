#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare to ${BOLD}${UNDERLINE}update ${THIS}${NC}"

export PATH="${HOME}/.pyenv/bin:$PATH"
export PATH="${HOME}/.goenv/bin:$PATH"
export PATH="${HOME}/.local/bin:$PATH"

# if asdf is installed
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true
command -v goenv > /dev/null && eval "$(goenv init -)" || true
################################################################

[[ ${VERBOSE} == "true" ]] &&
  log_info "Updating ${THIS_HL}..." ||
  start_spinner "Updating ${THIS_HL}..."
(

command -v asdf > /dev/null && for plugin in $(asdf plugin list); do asdf reshim $plugin; done || true
command -v pyenv > /dev/null && pyenv rehash || true
command -v goenv > /dev/null && goenv rehash || true

) >&3 2>&4 && exit_code="0" || exit_code="$?"
stop_spinner "${exit_code}" \
  "${THIS_HL} are updated [local]" \
  "${THIS_HL} udpate is failed [local]. use VERBOSE=true for error message"
