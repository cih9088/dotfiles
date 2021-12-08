#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/colours.sh
. ${DIR}/platform.sh
################################################################

log() {
  local TITLE="$1"; shift
  local CONTENT="$1"; shift
  local CODE=""
  for i in $@; do
    CODE="${CODE}${!i}"
  done
  printf "${CODE}${TITLE}${NC} ${CONTENT}\n" 1>&2
}

log_info() {
  log "[+]" "$1" "BOLD" "CYAN"
}

log_ok() {
  log "[*]" "$1" "BOLD" "GREEN"
}

log_error() {
  log "[!]" "$1" "BOLD" "RED"
}

log_question() {
  log "[?]" "$1" "BOLD" "YELLOW"
  read -p "    ${YELLOW}❯❯❯${NC} " ANSWER
  echo ${ANSWER}
}

log_title() {
  echo >&2
  log "[#]" "$1" "BOLD" "PURPLE"
  # log "[#] $1" "" "BOLD" "BLACK" "BGPURPLE"
}

# https://stackoverflow.com/a/4024263
verlte() {
  [ "$1" = $(printf '%s\n%s' $1 $2 | sort -V | head -n 1) ]
}

# https://stackoverflow.com/a/4024263
verlt() {
  [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

random-string() {
  local LENGTH=${1:-32}
  export LC_CTYPE=C
  export LANG=C
  if [ "${PLATFORM}" == "OSX" ]; then
    cat /dev/urandom | tr -dc 'a-zA-Z0-9\$\?' | fold -w ${LENGTH} | head -n 1
  else
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${LENGTH} | head -n 1
  fi
}

backup-and-link() {
  local SRC="$1"
  local TGT="$2"
  local BACKUP_PATH="$3"

  if [ -e ${TGT} ]; then
    log_info "Backup ${TGT} to ${BACKUP_PATH}"
    cp -RfL ${TGT} ${BACKUP_PATH}
    rm -rf ${TGT}
  fi
  ln -snf ${SRC} ${TGT}
}

has() {
  local verbose=0
  if [[ $1 = '-v' ]]; then
    verbose=1
    shift
  fi
  for c; do c="${c%% *}"
    if ! command -v "$c" &> /dev/null; then
      (( verbose > 0 )) && log_error "Command '$c' not found."
      return 1
    fi
  done
}
