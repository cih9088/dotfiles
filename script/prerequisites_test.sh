#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################


echo -e "\n-- python ------------------------------"
which -a python || echo "${IRed}python is not installed${Color_Off}"
echo -e "\n-- pip ---------------------------------"
which -a pip || echo "${IRed}pip is not installed${Color_Off}"
echo -e "\n-- python2 -----------------------------"
which -a python2 || echo "${IRed}python2 is not installed${Color_Off}"
echo -e "\n-- pip2 --------------------------------"
which -a pip2 || echo "${IRed}pip is not installed${Color_Off}"
echo -e "\n-- python3 -----------------------------"
which -a python3 || echo "${IRed}python3 is not installed${Color_Off}"
echo -e "\n-- pip3 --------------------------------"
which -a pip3 || echo "${IRed}pip2 is not installed${Color_Off}"
echo -e "\n-- wget --------------------------------"
which -a wget || echo "${IRed}wget is not installed${Color_Off}"
echo -e "\n-- curl --------------------------------"
which -a curl || echo "${IRed}curl is not installed${Color_Off}"
echo -e "\n-- git ---------------------------------"
which -a git || echo "${IRed}git is not installed${Color_Off}"
echo -e "\n-- column ------------------------------"
which -a column || echo "${IRed}column is not installed${Color_Off}"

if [[ $platform = "OSX" ]]; then
    echo -e "\n-- pbcopy ------------------------------"
    which -a pbcopy || echo "${IRed}pbcopy is not installed${Color_Off}"
    echo -e "\n-- pbpass ------------------------------"
    which -a pbpaste || echo "${IRed}pbpaste is not installed${Color_Off}"
    echo -e "\n-- reattach-to-user-namespace ----------"
    which -a reattach-to-user-namespace || echo "${IRed}reattach-to-user-namepsace is not installed${Color_Off}"
    echo -e "\n-- Xquartz -----------------------------"
    which -a xquartz || echo "${IRed}xquartz is not installed${Color_Off}"
elif [[ $platform = "LINUX" ]]; then
    echo -e "\n-- xclip -------------------------------"
    which -a xclip || echo "${IRed}xclip is not installed${Color_Off}"
fi
