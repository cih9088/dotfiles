#!/usr/bin/env bash

trap "clean_stdin; reveal_stdin" SIGINT SIGTERM EXIT

# Author: Tasos Latsas
# Modified: Inhyuk Andy Cho <cih9088@gmail.com>

# spinner.sh
#
# Display an awesome 'spinner' while running your long shell commands
#
# Do *NOT* call _spinner function directly.
# Use {start,stop}_spinner wrapper functions

# usage:
#   1. source this script in your's
#   2. start the spinner:
#       start_spinner [message]
#   3. run your command
#   4. stop the spinner:
#       stop_spinner [command's exit status] [meessage when success] [message when failed]
#
# Also see: test.sh

function hide_stdin() {
  if [ -t 0 ]; then
    stty -echo
    # stty -echo -icanon time 0 min 0
  fi
}

function reveal_stdin() {
  if [ -t 0 ]; then
    stty echo
  fi
}

function clean_stdin() {
  if [ -t 0 ]; then
    # while read -e -t 0.1; do : ; done
    # while read -e -t 1; do : ; done
    while read -r -t 0; do read -r; done
  fi
}

function _spinner() {
  # $1 start/stop
  #
  # on start: $2 display message
  #           $3 message length
  # on stop : $2 process exit status
  #           $3 spinner function pid (supplied from stop_spinner)
  #           $4 message length
  #           $5 message done
  #           $6 message failed

  local GREEN='[1;32m'
  local RED='[1;31m'
  local YELLOW='[1;33m'
  local NC='[0m'

  case $1 in
    start)
      local msg=$2
      local ctr=$3

      # start spinner
      i=1
      sp='\|/-'
      delay=${SPINNER_DELAY:-0.15}

      while :
      do
          printf "\033[2K\033[${ctr}D${YELLOW}[${sp:$((i++%${#sp})):1}]${NC} ${msg}"
          sleep $delay
      done
      ;;
    stop)
      local exit_status=$2
      local pid=$3
      local ctr=$4
      local msg_done=$5
      local msg_failed=$6

      if [[ ! -z ${pid} ]]; then
          kill ${pid} > /dev/null 2>&1
      fi

      # inform the user uppon success or failure
      if [[ ${exit_status} -eq 0 ]]; then
          printf "\033[2K\033[${ctr}D${GREEN}[*]${NC} ${msg_done}\n"
      else
          printf "\033[2K\033[${ctr}D${RED}[!]${NC} ${msg_failed}\n"
      fi
      ;;
    *)
      printf "invalid argument, try {start/stop}\n"
      exit 1
      ;;
  esac
}

function start_spinner {
  # $1 : msg to display
  # count mesg length
  ctr=4
  for (( i = 1; i <= $(printf "${1}" | expand | wc -m ); i++ )); do
    ctr=$(( $ctr + 1 ))
  done
  _spinner "start" "${1}" "${ctr}" &
  # set global spinner pid
  _sp_pid=$!
  hide_stdin
  disown
}

function stop_spinner {
  # $1 : command exit status
  # $2 : msg to display when done
  # $3 : msg to dispaly when failed

  _spinner "stop" "${1}" "${_sp_pid:-}" "${ctr:-}" "${2:-DONE}" "${3:-FAILED}"
  clean_stdin
  reveal_stdin
  unset _sp_pid
}

