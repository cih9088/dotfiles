#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing c dev..."
(
    # ccls
    rm -rf ${HOME}/.ccls || true
    git clone --depth=1 --recursive https://github.com/MaskRay/ccls ${HOME}/.ccls

    (
    cd ${HOME}/.ccls
    if [[ $platform == "OSX" ]]; then
        wget https://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz
        tar -xJf clang+llvm-8.0.0-x86_64-apple-darwin.tar.xz
        cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${HOME}/.local -DCMAKE_PREFIX_PATH=clang+llvm-8.0.0-x86_64-apple-darwin
    elif [[ $platform == "LINUX" ]]; then
        wget https://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
        tar -xJf https://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
        cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${HOME}/.local -DCMAKE_PREFIX_PATH=clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-18.04
    fi

    cmake --build Release --target install 
    )

    coc_languageserver='
        "ccls": {
            "command": "ccls",
            "filetypes": ["c", "cpp", "objc", "objcpp"],
            "rootPatterns": [".ccls", "compile_commands.json", ".vim/", ".git/", ".hg/"],
            "initializationOptions": {
                "cacheDirectory": "/tmp/ccls"
            }
        }
'

    # write languageserver, delete empty line first, delete empty line last, insert comma
    sed -e '/"languageserver":/r '<(echo "${coc_languageserver}") ${PROJ_HOME}/nvim/coc-settings.json | \
        sed -e '/"languageserver":/{n;d;}' | \
        tac | sed -e '/^    }$/ N;s/^    }\n$/    }/;' | tac | \
        sed -e '/"languageserver":/,/^    }$/ s/^[[:space:]]*$/        ,/' > ${TMP_DIR}/tmp

    rm -rf ${PROJ_HOME}/nvim/coc-settings.json || true
    mv ${TMP_DIR}/tmp ${PROJ_HOME}/nvim/coc-settings.json

) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "c dev are updated [local]" \
    "c dev udpate is failed [local]. use VERBOSE=YES for error message"



# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
