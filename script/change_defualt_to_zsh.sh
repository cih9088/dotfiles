#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

local_change() {
    if [[ -e $HOME/.local/bin/zsh ]]; then
        if grep -Fxq "exec $HOME/.local/bin/zsh -l" $HOME/.bashrc; then
            :
        else
            echo -e "if [[ -e $HOME/.local/bin/zsh ]]; then\n\texec $HOME/.local/bin/zsh -l\nfi" >> $HOME/.bashrc
        fi
    else
        echo "${marker_err} $HOME/.local/bin/zsh does not exist"
        false
    fi
}

system_change() {
    if [[ $platform == "OSX" ]]; then
        chsh -s "/usr/local/bin/zsh" || chsh -s "/bin/zsh"
    elif [[ $platform == "LINUX" ]]; then
        chsh -s "/usr/bin/zsh" || chsh -s "/bin/zsh"
    fi
}

# change default shell to zsh
echo
if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_changeDefaultShell_change} == "yes" ]]; then
        if [[ ${CONFIG_changeDefaultShell_local} == "yes" ]]; then
            local_change \
            && echo "${marker_ok} Changed default shell to local zsh" \
            || echo "${marker_err} Change default shell to local zsh is failed"
        elif [[ ${CONFIG_changeDefaultShell_local} == "no" ]]; then
            system_change \
            && echo "${marker_ok} Changed default shell to systemwide zsh" \
            || echo "${marker_err} Change default shell to system zsh is failed"
        fi
    else
        echo "${marker_ok} Default shell is unchanged"
    fi
else
    while true; do
        read -p "${marker_que} Do you wish to change default shell to zsh? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_ok} Default shell is unchanged"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Change default shell to local zsh or systemwide zsh? " yn
        case $yn in
            [Ll]ocal* ) 
                local_change \
                    && echo "${marker_ok} Changed default shell to local zsh" \
                    || echo "${marker_err} Change default shell to local zsh is failed"
                break;;
            [Ss]ystem* )
                system_change \
                    && echo "${marker_ok} Changed default shell to systemwide zsh" \
                    || echo "${marker_err} Change default shell to systemwide zsh is failed"
                break;;
            * ) echo "${marker_err} Please answer locally or systemwide";;
        esac
    done
fi

