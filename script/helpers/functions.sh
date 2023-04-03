#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/colours.sh
. ${DIR}/platform.sh
################################################################


get_cursor_position() {
  # based on a script from http://invisible-island.net/xterm/xterm.faq.html
  if [ -t 0 ]; then
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    # on my system, the following line can be replaced by the line below it
    echo -en "\033[6n" > /dev/tty
    # tput u7 > /dev/tty    # when TERM=xterm (and relatives)
    IFS=';' read -r -d R -a pos
    stty $oldstty
    # change from one-based to zero based so they work with: tput cup $row $col
    row=$((${pos[0]:2} - 1))    # strip off the esc-[
    col=$((${pos[1]} - 1))
    echo ${row}:${col}
  fi
}

strip_ansi() {
  echo "$1" | sed "s/\x1B\[[0-9;]*[JKmsu]//g"
}

log() {
  local TITLE="$1"; shift
  local CONTENT="$1"; shift
  local CODE=""
  local MESSAGE
  for i in "$@"; do
    CODE="${CODE}${!i}"
  done

  MESSAGE="${CODE}${TITLE}${NC} ${CONTENT}\n"

  # if [[ "$(get_cursor_position)" != *":0" ]]; then
  #   echo "" >&2
  # fi
  if [ ! -t 2 ]; then
    MESSAGE="$(strip_ansi "$MESSAGE")"
  fi

  printf "$MESSAGE" >&2
}

log_verbose() {
  local TITLE="$1"; shift
  local CONTENT="$1"; shift
  local CODE=""
  local MESSAGE=""
  for i in "$@"; do
    CODE="${CODE}${!i}"
  done

  MESSAGE="${CODE}${TITLE}${NC} ${CONTENT}\n"

  if ( exec 1>&5 ) 2>&-; then
    # if [[ "$(get_cursor_position)" != *":0" ]]; then
    #   echo "" >&5
    # fi
    if [ ! -t 5 ]; then
      MESSAGE="$(strip_ansi "$MESSAGE")"
    fi
    printf "$MESSAGE" >&5
  else
    # if [[ "$(get_cursor_position)" != *":0" ]]; then
    #   echo "" >&2
    # fi
    if [ ! -t 2 ]; then
      MESSAGE="$(strip_ansi "$MESSAGE")"
    fi
    printf "$MESSAGE" >&2
  fi
}

log_info() {
  log "[+]" "$1" "BOLD" "CYAN"
}

log_ok() {
  log "[*]" "$1" "BOLD" "GREEN"
}

log_error() {
  log_verbose "[!]" "$1" "BOLD" "RED"
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

backup() {
  local TGT="$1"
  local BACKUP_PATH="$2"

  if [ -e ${TGT} ]; then
    log_info "Backup ${TGT} to ${BACKUP_PATH}"
    cp -RfL ${TGT} ${BACKUP_PATH}
    rm -rf ${TGT}
  fi
}

backup-and-link() {
  local SRC="$1"
  local TGT="$2"
  local BACKUP_PATH="$3"

  mkdir -p $(dirname $TGT)
  mkdir -p $(dirname $BACKUP_PATH)

  backup ${TGT} ${BACKUP_PATH}
  log_info "Update symbolic link '${SRC}' -> '${TGT}'"
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

intelli_pip3() {
  local _PY_ORIGIN=
  local _COMMAND="$1"
  shift

  command -v python3 >/dev/null 2>&1 &&
    _PY_ORIGIN=$(
    python3 << EOF
import os, sys

prefix = sys.prefix
base_prefix = sys.base_prefix
homedir = os.path.expanduser("~")

if prefix != base_prefix:
  print("virtualenv")
elif prefix.startswith(homedir):
  print("local")
else:
  print("system")
EOF
  )

  if [ $_PY_ORIGIN == "system" ] && [[ "$@" = "uninstall"* ]]; then
    pip3 $_COMMAND --user $@
  else
    pip3 $_COMMAND $@
  fi

  command -v asdf >/dev/null 2>&1 && asdf reshim || true
  command -v pyenv >/dev/null 2>&1 && pyenv rehash || true
}

++() {
  # set -f  # no double expand
  eval "$@" || exit $?
}


wrap() {
  eval "$1() { $2 }"
}

unwrap() {
  for i in "$@"; do
    unset -f "$i"
  done
}

wrap_sudo() {
  for i in "$@"; do
    eval "$i"'() { sudo $(type -ap ${FUNCNAME[0]}) "$@"; }'
  done
}
