#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install shell environment${Color_Off}"
################################################################

setup_func_shellcheck_local() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        echo "${marker_err} Not available on OSX"
        exit 1
    elif [[ $platform == "LINUX" ]]; then

        install=no
        if [ -f ${HOME}/.local/bin/shellcheck ]; then
            if [ ${force} == 'true' ]; then
                rm -rf $HOME/.local/bin/shellcheck || true
                install='true'
            fi
        else
            install='true'
        fi

        if [ ${install} == 'true' ]; then
            wget https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz
            tar -xvJf shellcheck-stable.linux.x86_64.tar.xz
            cd shellcheck-stable
            yes | \cp -rf shellcheck $HOME/.local/bin
        fi
    fi
}

setup_func_shellcheck_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install shellcheck
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get -y install shellcheck
    fi
}

version_func_shellcheck() {
    $1 --version | head -2 | tail -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

setup_func_bash_language_server_local() {
    force=$1
    cd $TMP_DIR

    npm i -g bash-language-server

    coc_languageserver='
        "bash": {
            "command": "bash-language-server",
            "args": ["start"],
            "filetypes": ["sh"],
            "ignoredRootPaths": ["~"]
        }
'

    # write languageserver, delete empty line first, delete empty line last, insert comma
    sed -e '/"languageserver":/r '<(echo "${coc_languageserver}") ${PROJ_HOME}/nvim/coc-settings.json | \
        sed -e '/"languageserver":/{n;d;}' | \
        tac | sed -e '/^    }$/ N;s/^    }\n$/    }/;' | tac | \
        sed -e '/"languageserver":/,/^    }$/ s/^[[:space:]]*$/        ,/' > ${TMP_DIR}/tmp

    rm -rf ${PROJ_HOME}/nvim/coc-settings.json || true
    mv ${TMP_DIR}/tmp ${PROJ_HOME}/nvim/coc-settings.json
}

setup_func_bash_language_server_system() {
    setup_func_bash_language_server_local $@
}

version_func_bash_language_server() {
    $1 --version | head -2 | tail -1
}

main_script 'shellcheck' setup_func_shellcheck_local setup_func_shellcheck_system version_func_shellcheck

main_script 'bash_language_server' setup_func_bash_language_server_local setup_func_bash_language_server_system version_func_bash_language_server
