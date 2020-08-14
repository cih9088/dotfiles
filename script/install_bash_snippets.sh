#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to install bash_snippets"
################################################################

setup_func_bash_snippets_local() {
    force=$1
    cd $TMP_DIR

    git clone https://github.com/alexanderepstein/Bash-Snippets
    cd Bash-Snippets

    ./install.sh --prefix=$HOME/.local transfer cheat
}

setup_func_bash_snippets_system() {
    force=$1
    cd $TMP_DIR

    git clone https://github.com/alexanderepstein/Bash-Snippets
    cd Bash-Snippets

    if [[ $platform == "OSX" ]]; then
        brew install bash-snippets
    elif [[ $platform == "LINUX" ]]; then
        ./install.sh transfer cheat
    fi
}

main_script 'bash_snippets' setup_func_bash_snippets_local setup_func_bash_snippets_system
