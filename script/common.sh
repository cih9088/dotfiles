#!/usr/bin/env bash

set -e
################## Color ##########################

# Reset
Color_Off='[0m'       # Text Reset

# Regular Colors
Black='[0;30m'        # Black
Red='[0;31m'          # Red
Green='[0;32m'        # Green
Yellow='[0;33m'       # Yellow
Blue='[0;34m'         # Blue
Purple='[0;35m'       # Purple
Cyan='[0;36m'         # Cyan
White='[0;37m'        # White

# Bold
BBlack='[1;30m'       # Black
BRed='[1;31m'         # Red
BGreen='[1;32m'       # Green
BYellow='[1;33m'      # Yellow
BBlue='[1;34m'        # Blue
BPurple='[1;35m'      # Purple
BCyan='[1;36m'        # Cyan
BWhite='[1;37m'       # White

# Underline
UBlack='[4;30m'       # Black
URed='[4;31m'         # Red
UGreen='[4;32m'       # Green
UYellow='[4;33m'      # Yellow
UBlue='[4;34m'        # Blue
UPurple='[4;35m'      # Purple
UCyan='[4;36m'        # Cyan
UWhite='[4;37m'       # White

# Background
On_Black='[40m'       # Black
On_Red='[41m'         # Red
On_Green='[42m'       # Green
On_Yellow='[43m'      # Yellow
On_Blue='[44m'        # Blue
On_Purple='[45m'      # Purple
On_Cyan='[46m'        # Cyan
On_White='[47m'       # White

# High Intensity
IBlack='[0;90m'       # Black
IRed='[0;91m'         # Red
IGreen='[0;92m'       # Green
IYellow='[0;93m'      # Yellow
IBlue='[0;94m'        # Blue
IPurple='[0;95m'      # Purple
ICyan='[0;96m'        # Cyan
IWhite='[0;97m'       # White

# Bold High Intensity
BIBlack='[1;90m'      # Black
BIRed='[1;91m'        # Red
BIGreen='[1;92m'      # Green
BIYellow='[1;93m'     # Yellow
BIBlue='[1;94m'       # Blue
BIPurple='[1;95m'     # Purple
BICyan='[1;96m'       # Cyan
BIWhite='[1;97m'      # White

# High Intensity backgrounds
On_IBlack='[0;100m'   # Black
On_IRed='[0;101m'     # Red
On_IGreen='[0;102m'   # Green
On_IYellow='[0;103m'  # Yellow
On_IBlue='[0;104m'    # Blue
On_IPurple='[0;105m'  # Purple
On_ICyan='[0;106m'    # Cyan
On_IWhite='[0;107m'   # White

##################################################

marker_ok="${IGreen}[*]${Color_Off}"
marker_err="${IRed}[!]${Color_Off}"
marker_info="${IYellow}[+]${Color_Off}"
marker_que="${ICyan}[?]${Color_Off}"


case "$OSTYPE" in
    solaris*) platform="SOLARIS" ;;
    darwin*)  platform="OSX" ;;
    linux*)   platform="LINUX" ;;
    bsd*)     platform="BSD" ;;
    msys*)    platform="WINDOWS" ;;
    *)        platform="unknown: $OSTYPE" ;;
esac

if [[ $platform != OSX && $platform != LINUX ]]; then
    echo "${marker_err} $platform is not supported." >&2; exit 1
fi

if [[ $$ = $BASHPID ]]; then
    PROJ_HOME=${PROJ_HOME:=$(git rev-parse --show-toplevel)}
    TMP_DIR=${TMP_DIR:=${HOME}/tmp_install}
    VERBOSE=${VERBOSE:=}
    BIN_DIR=${BIN_DIR:=${PROJ_HOME}/bin}

    if [ ! -d $HOME/.local/bin ]; then
        mkdir -p $HOME/.local/bin
    fi

    if [ ! -d $HOME/.local/src ]; then
        mkdir -p $HOME/.local/src
    fi

    if [ ! -d $HOME/.local/shared ]; then
        mkdir -p $HOME/.local/shared
    fi

    if [ ! -d $HOME/.local/man/man1 ]; then
        mkdir -p $HOME/.local/man/man1
    fi

    if [ ! -d $HOME/.config ]; then
        mkdir -p $HOME/.config
    fi

    if [ ! -d $TMP_DIR ]; then
        mkdir -p $TMP_DIR
    fi
fi

spinner() {
    local info="$1"
    local pid="$!"
    local delay=0.75
    local spinstr='|/-\'
    local ctr=0
    for (( i = 1; i <= $(printf "$info  [%c] " "$spinstr" | expand | wc -m ); i++ )); do
        local ctr=$(( $ctr + 1 ))
    done
    while kill -0 $pid 2> /dev/null; do
        local temp=${spinstr#?}
        printf "$info  [%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\033[2K \033[${ctr}D"
    done
}

[[ ! -z ${CONFIG+x} ]] && eval $(${PROJ_HOME}/script/parser_yaml ${CONFIG} "CONFIG_") || true
[[ "${VERBOSE:=NO}" == "YES" ]] && exec 3>&1 4>&2 || exec 3>/dev/null 4>/dev/null
trap "rm -rf ${TMP_DIR}" SIGINT SIGTERM EXIT
# [[ "${BASH_SOURCE[0]}" != "${0}" ]] && echo "script ${BASH_SOURCE[0]} is being sourced ..."
# [[ "${BASH_SUBSHELL}" != 0 ]] && echo "It is in subshll" || echo "It is not subshell"
