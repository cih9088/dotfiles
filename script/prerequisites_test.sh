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

log_title "Essential to install"
log_info "git"
type -a git 2>/dev/null || echo "${IRED}git is not found.${NC}"
log_info "make"
type -a make 2>/dev/null || echo "${IRED}make is not found.${NC}"
log_info "cmake"
type -a cmake 2>/dev/null || echo "${IRED}cmake is not found.${NC}"
log_info "gcc"
type -a gcc 2>/dev/null || echo "${IRED}gcc is not found.${NC}"
log_info "g++"
type -a g++ 2>/dev/null || echo "${IRED}g++ is not found.${NC}"
log_info "wget"
type -a wget 2>/dev/null || echo "${IRED}wget is not found.${NC}"
log_info "curl"
type -a curl 2>/dev/null || echo "${IRED}curl is not found.${NC}"
log_info "sudo"
type -a sudo 2>/dev/null || echo "${IRED}sudo is not found.${NC}"
log_info "unzip"
type -a unzip 2>/dev/null || echo "${IRED}unzip is not found.${NC}"
log_info "column"
type -a column 2>/dev/null || echo "${IRED}column is not found.${NC}"
log_info "find"
type -a find 2>/dev/null || echo "${IRED}find is not found.${NC}"

log_title "Good to have"
if [[ ${PLATFORM} = "OSX" ]]; then
  log_info "pbcopy"
  type -a pbcopy 2>/dev/null || echo "${IYELLOW}pbcopy is not found.${NC}"
  log_info "pbpaste"
  type -a pbpaste 2>/dev/null || echo "${IYELLOW}pbpaste is not found.${NC}"
  log_info "reattach-to-user-namespace"
  type -a reattach-to-user-namespace 2>/dev/null || echo "${IYELLOW}reattach-to-user-namepsace is not found.${NC}"
  log_info "xquartz"
  type -a xquartz 2>/dev/null || echo "${IYELLOW}xquartz is not found.${NC}"
elif [[ ${PLATFORM} = "LINUX" ]]; then
  log_info "xclip"
  type -a xclip 2>/dev/null || echo "${IYELLOW}xclip is not found.${NC}"
fi
