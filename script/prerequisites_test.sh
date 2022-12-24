#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/helpers/common.sh
################################################################

has -v type
################################################################

# clean up duplicated path
PATH=$(printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')


log_title "Essentials"
cmds=( sudo git make curl sed awk find )
for cmd in "${cmds[@]}"; do
  type -a "$cmd" &>/dev/null \
    && log_ok "${BOLD}$cmd${NC} is in paths." \
    || log_error "${IRED}${BOLD}$cmd${NC} is not in paths."
done


log_title "Essentials for local mode"
cmds=( gcc g++ tar )
for cmd in "${cmds[@]}"; do
  type -a "$cmd" &>/dev/null \
    && log_ok "${BOLD}$cmd${NC} is in paths." \
    || log_error "${IRED}${BOLD}$cmd${NC} is not in paths."
done


if [[ ${PLATFORM} = "OSX" ]]; then
  log_title "Optionals"
  cmds=( pbcopy pbpaste xquartz )
elif [[ ${PLATFORM} = "LINUX" ]]; then
  log_title "Optionals"
  cmds=( xclip )
else
  cmds=()
fi
for cmd in "${cmds[@]}"; do
  type -a "$cmd" &>/dev/null \
    && log_ok "${BOLD}$cmd${NC} is in paths." \
    || log_error "${IYELLOW}${BOLD}$cmd${NC} is not in paths."
done
