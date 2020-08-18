#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install bash_snippets${Color_Off}"
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

    if [[ $platform == "OSX" ]]; then
        brew list bash-snippets || brew install bash-snippets
        if [ ${force} == 'true' ]; then
            brew upgrade bash-snippets
        fi
    elif [[ $platform == "LINUX" ]]; then
        git clone https://github.com/alexanderepstein/Bash-Snippets
        cd Bash-Snippets
        ./install.sh transfer cheat
    fi
}

main_script 'bash_snippets' setup_func_bash_snippets_local setup_func_bash_snippets_system
