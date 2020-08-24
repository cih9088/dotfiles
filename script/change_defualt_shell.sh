#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh

TARGET_SHELL=""
################################################################

local_change() {
    shell_full_path="${HOME}/.local/bin/$1"
    # loginshell_rc=".${SHELL##*/}rc"
    # assume default login shell is bash
    loginshell_rc=".bashrc"

    # sed -i -e '/'$(echo $shell_full_path | sed 's/\//\\\//g')' ]]; then/,/fi/d' ${HOME}/${loginshell_rc}
    sed -i -e '/# added from andys dotfiles/,/^fi$/d' ${HOME}/${loginshell_rc}

    if [[ -e ${shell_full_path} ]]; then
        # echo -e "if [[ -e ${shell_full_path} ]]; then\n\texec ${shell_full_path} -l\nfi" >> ${HOME}/${loginshell_rc}
        echo -e "# added from andys dotfiles" >> ${HOME}/${loginshell_rc}
        echo -e "if [[ -e ${shell_full_path} ]]; then \n\texec env -i TERM="$TERM" HOME="$HOME" SHELL="${shell_full_path}" ${shell_full_path} -il\nfi" >> ${HOME}/${loginshell_rc}
    else
        echo "${marker_err} ${shell_full_path} does not exist"
        false
    fi
}

system_change() {
    shell_full_path=$1
    if [[ $platform == "OSX" ]]; then
        shell_full_path="/usr/local/bin/${shell_full_path}"
    elif [[ $platform == "LINUX" ]]; then
        shell_full_path="/usr/bin/${shell_full_path}"
    fi

    chsh -s "${shell_full_path}"
}

main() {
    # change default shell to zsh
    echo
    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_changeDefaultShell_change} == "true" ]]; then
            if [[ ${CONFIG_changeDefaultShell_local} == "true" ]]; then
                local_change ${CONFIG_changeDefaultShell_shell} \
                && echo "${marker_ok} Changed default shell to local zsh" \
                || echo "${marker_err} Change default shell to local zsh is failed"
            elif [[ ${CONFIG_changeDefaultShell_local} == "no" ]]; then
                system_change ${CONFIG_changeDefaultShell_shell} \
                && echo "${marker_ok} Changed default shell to systemwide zsh" \
                || echo "${marker_err} Change default shell to system zsh is failed"
            fi
        else
            echo "${marker_ok} Default shell is unchanged"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to change default shell? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_ok} Default shell is unchanged"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Which shell? [zsh/fish] " yn
            case $yn in
                zsh ) TARGET_SHELL="zsh"; ;;
                fish ) TARGET_SHELL="fish"; ;;
                * ) echo "${marker_err} Please answer zsh or fish"; continue;;
            esac

            read -p "${marker_que} Change default shell to local ${TARGET_SHELL} or systemwide ${TARGET_SHELL}? " yn
            case $yn in
                [Ll]ocal* ) 
                    local_change ${TARGET_SHELL} \
                        && echo "${marker_ok} Changed default shell to local ${TARGET_SHELL}" \
                        || echo "${marker_err} Change default shell to local ${TARGET_SHELL} is failed"
                    break;;
                [Ss]ystem* )
                    system_change ${TARGET_SHELL} \
                        && echo "${marker_ok} Changed default shell to systemwide ${TARGET_SHELL}" \
                        || echo "${marker_err} Change default shell to systemwide ${TARGET_SHELL} is failed"
                    break;;
                * ) echo "${marker_err} Please answer locally or systemwide";;
            esac
        done
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}

main "$@"
