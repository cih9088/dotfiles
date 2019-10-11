#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/spinner/spinner.sh
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


# if [[ $$ = $BASHPID ]]; then
# fi

PROJ_HOME=${PROJ_HOME:=$(git rev-parse --show-toplevel)}
TMP_DIR=${TMP_DIR:=${HOME}/tmp_install}
VERBOSE=$(echo ${VERBOSE:-NO} | tr '[:upper:]' '[:lower:]')
FORCE=$(echo ${FORCE:-NO} | tr '[:upper:]' '[:lower:]')
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

[[ ! -z ${CONFIG+x} ]] && eval $(${PROJ_HOME}/script/parser_yaml ${CONFIG} "CONFIG_") || true
[[ "${VERBOSE}" == "yes" ]] && exec 3>&1 4>&2 || exec 3>/dev/null 4>/dev/null
trap "rm -rf ${TMP_DIR}" SIGINT SIGTERM EXIT
# [[ "${BASH_SOURCE[0]}" != "${0}" ]] && echo "script ${BASH_SOURCE[0]} is being sourced ..."
# [[ "${BASH_SUBSHELL}" != 0 ]] && echo "It is in subshll" || echo "It is not subshell"


main_script() {
    local target=$1
    local setup_func_local=$2
    local setup_func_system=$3
    local version_func=$4

    if [ -z ${target+x} ]; then
        echo 'target is unset' >&2
    fi
    if [ -z ${setup_func_local+x} ]; then
        echo 'setup_func_local is unset' >&2
    fi
    if [ -z ${setup_func_system+x} ]; then
        echo 'setup_func_system is unset' >&2
    fi

    echo
    if [ ! -z ${version_func+x} ]; then
        if [ -x "$(command -v ${target})" ]; then
            echo "${marker_info} Following list is ${target} installed on the system"
            coms=($(which -a ${target} | uniq))
            (
                printf 'LOCATION,VERSION\n'
                for com in "${coms[@]}"; do
                    printf '%s,%s\n' "${com}" "$( ${version_func} ${com} )"
                done
            ) | column -t -s ',' | sed 's/^/    /'
        else
            echo "${marker_info} ${target} is not found on the system"
        fi
    fi

    if [ ! -d $TMP_DIR ]; then
        mkdir -p $TMP_DIR
    fi

    if [[ ! -z ${CONFIG+x} ]]; then
        target_install="CONFIG_${target}_install"
        target_local="CONFIG_${target}_local"
        target_force="CONFIG_${target}_force"
        target_install=${!target_install:-no}
        target_local=${!target_local:-yes}
        target_force=${!target_force:-no}

        if [[ ${target_install} == "yes" ]]; then
            [[ ${VERBOSE} == yes ]] || start_spinner "Installing ${target}... [force: ${target_force}]"
            (
                [[ ${target_local} == "yes" ]] \
                    && ${setup_func_local} ${target_force} \
                    || ${setup_func_system} ${target_force}
            ) >&3 2>&4 || exit_code="$?" && true
            stop_spinner "${exit_code}" \
                "${target} is installed [force: ${target_force}]" \
                "${target} install is failed [force: ${target_force}]. use VERBOSE=YES for debugging"
        else
            echo "${marker_ok} ${target} is not installed"
        fi
    else
        target_force=${FORCE}
        while true; do
            read -p "${marker_que} Do you wish to install ${target}? (force_install: ${target_force}) " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install ${target}"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* )
                    echo "${marker_info} Install ${target} ${nodejs_VERSION} locally"
                    [[ ${VERBOSE} == yes ]] || start_spinner "Installing ${target}... [force: ${target_force}]"
                    (
                        ${setup_func_local} ${target_force}
                    ) >&3 2>&4 || exit_code="$?" && true
                    stop_spinner "${exit_code}" \
                        "${target} is installed [force: ${target_force}]" \
                        "${target} install is failed [force: ${target_force}]. use VERBOSE=YES for debugging"
                    break;;
                [Ss]ystem* )
                    echo "${marker_info} Install latest ${target} systemwide"
                    [[ ${VERBOSE} == yes ]] || start_spinner "Installing ${target}... [force: ${target_force}]"
                    (
                        ${setup_func_system} ${target_force}
                    ) >&3 2>&4 || exit_code="$?" && true
                    stop_spinner "${exit_code}" \
                        "${target} is installed [force: ${target_force}]" \
                        "${target} install is failed [force: ${target_force}]. use VERBOSE=YES for debugging"
                    break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}
