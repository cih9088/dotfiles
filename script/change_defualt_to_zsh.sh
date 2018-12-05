#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

local_change() {
    if grep -Fxq "exec $HOME/.local/bin/zsh -l" $HOME/.bashrc; then
        :
    else
        echo -e "if [[ -e $HOME/.local/bin/zsh ]]; then\n\texec $HOME/.local/bin/zsh -l\nfi" >> $HOME/.bashrc
    fi
}

system_change() {
    chsh -s $(which zsh)
}

# change default shell to zsh
echo
if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_changeDefaultShell_change} == "yes" ]]; then
        [[ ${CONFIG_changeDefaultShell_local} == "yes" ]] && local_change && echo "${marker_ok} Changed default shell to local zsh" || true
        [[ ${CONFIG_changeDefaultShell_local} == "no" ]] && system_change && echo "${marker_ok} Changed default shell to systemwide zsh" ||true
    else
        echo "${marker_err} zsh is not installed"
    fi
else
    while true; do
        read -p "${marker_que} Do you wish to change default shell to zsh? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_ok} Default shell is unchanged..."; break;;
            * ) echo "${marker_err} Please answer yes or no."; continue;;
        esac

        read -p "${marker_que} Change default shell to local zsh or systemwide zsh? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_ok} Changed default shell to local zsh"; local_change; break;;
            [Ss]ystem* ) echo "${marker_ok} Changed default shell to systemwide zsh"; system_change; break;;
            * ) echo "${marker_err} Please answer locally or systemwide.";;
        esac
    done
fi

