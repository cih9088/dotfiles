#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

# change default shell to zsh
while true; do
    echo
    read -p "${marker_que} Do you wish to change default shell to zsh? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "${marker_ok} Default shell is unchanged..."; break;;
        * ) echo "${marker_err} Please answer yes or no."; continue;;
    esac

    read -p "${marker_que} Change default shell to local zsh or systemwide zsh? " yn
    case $yn in
        [Ll]ocal* ) echo "${marker_ok} Changed default shell to local zsh"
            if grep -Fxq "exec $HOME/.local/bin/zsh -l" $HOME/.bashrc; then
                :
            else
                echo -e "if [[ -e $HOME/.local/bin/zsh ]]; then\n\texec $HOME/.local/bin/zsh -l\nfi" >> $HOME/.bashrc
            fi
            break;;
        [Ss]ystem* ) echo "${marker_ok} Changed default shell to systemwide zsh"
            chsh -s $(which zsh); break;;
        * ) echo "${marker_err} Please answer locally or systemwide.";;
    esac
done
