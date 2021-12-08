#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/helpers/common.sh
################################################################

has -v make git which sudo
################################################################

# clean up duplicated path
PATH=$(printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')

log_title "Essential to install"
log_info "git"
which -a git || echo "${IRED}git is not found.${NC}"
log_info "make"
which -a make || echo "${IRED}make is not found.${NC}"
log_info "cmake"
which -a cmake || echo "${IRED}cmake is not found.${NC}"
log_info "gcc"
which -a gcc || echo "${IRED}gcc is not found.${NC}"
log_info "g++"
which -a g++ || echo "${IRED}g++ is not found.${NC}"
log_info "wget"
which -a wget || echo "${IRED}wget is not found.${NC}"
log_info "curl"
which -a curl || echo "${IRED}curl is not found.${NC}"
log_info "sudo"
which -a sudo || echo "${IRED}sudo is not found.${NC}"
log_info "unzip"
which -a unzip || echo "${IRED}unzip is not found.${NC}"
log_info "column"
which -a column || echo "${IRED}column is not found.${NC}"
log_info "find"
which -a find || echo "${IRED}find is not found.${NC}"

log_title "Good to have"
if [[ ${PLATFORM} = "OSX" ]]; then
  log_info "pbcopy"
  which -a pbcopy || echo "${IYELLOW}pbcopy is not found.${NC}"
  log_info "pbpaste"
  which -a pbpaste || echo "${IYELLOW}pbpaste is not found.${NC}"
  log_info "reattach-to-user-namespace"
  which -a reattach-to-user-namespace || echo "${IYELLOW}reattach-to-user-namepsace is not found.${NC}"
  log_info "xquartz"
  which -a xquartz || echo "${IYELLOW}xquartz is not found.${NC}"
elif [[ ${PLATFORM} = "LINUX" ]]; then
  log_info "xclip"
  which -a xclip || echo "${IYELLOW}xclip is not found.${NC}"
fi
