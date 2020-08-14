#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################


which -a python || echo "${IRed}python is not installed${Color_Off}"
which -a pip || echo "${IRed}pip is not installed${Color_Off}"
which -a python2 || echo "${IRed}python2 is not installed${Color_Off}"
which -a pip3 || echo "${IRed}pip2 is not installed${Color_Off}"
which -a python3 || echo "${IRed}python3 is not installed${Color_Off}"
which -a pip3 || echo "${IRed}pip3 is not installed${Color_Off}"
which -a wget || echo "${IRed}wget is not installed${Color_Off}"
which -a curl || echo "${IRed}curl is not installed${Color_Off}"
which -a git || echo "${IRed}git is not installed${Color_Off}"
which -a column || echo "${IRed}column is not installed${Color_Off}"

if [[ $platform == "OSX" ]]; then
    which -a pbcopy || echo "${IRed}pbcopy is not installed${Color_Off}"
    which -a pbpaste || echo "${IRed}pbpaste is not installed${Color_Off}"
    which -a reattach-to-user-namespace || echo "${IRed}reattach-to-user-namepsace is not installed${Color_Off}"
    which -a xquartz || echo "${IRed}xquartz is not installed${Color_Off}"
elif [[ $platform == "LINUX" ]]; then
    which -a xclip || echo "${IRed}xclip is not installed${Color_Off}"
fi
