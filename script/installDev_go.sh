#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install golang environment${Color_Off}"

# use sytem python
export GOENV_ROOT=${HOME}/.goenv

export PATH="${HOME}/.goenv/bin:$PATH"
################################################################

setup_func_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${GOENV_ROOT}/bin/goenv)" ]; then
        if [ ${force} == 'true' ]; then
            rm -rf ${GOENV_ROOT} || true
            install='true'
        fi
    else
        install='true'
    fi

    if [ ${install} == 'true' ]; then
        git clone https://github.com/syndbg/goenv.git ${GOENV_ROOT}
        git clone https://github.com/momo-lab/xxenv-latest.git ${GOENV_ROOT}/plugins/xxenv-latest
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    # https://github.com/syndbg/goenv/issues/80
    # no stable version is released yet
    if [[ $platform == "OSX" ]]; then
        brew list goenv || brew install --HEAD goenv
        [ -d ${GOENV_ROOT}/plugins/xxenv-latest ] \
            || git clone https://github.com/momo-lab/xxenv-latest.git ${GOENV_ROOT}/plugins/xxenv-latest

        if [ ${force} == 'true' ]; then
            brew upgrade --fetch-HEAD goenv
            rm -rf ${GOENV_ROOT}/plugins/xxenv-latest || true
            git clone https://github.com/momo-lab/xxenv-latest.git ${GOENV_ROOT}/plugins/xxenv-latest
        fi
    else
        setup_func_local ${force}
    fi

}

version_func() {
    $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

golang_install() {
    if ! command -v goenv > /dev/null; then
        echo "${marker_err} goenv is not found" >&2
        echo "${marker_err} Please install goenv first with 'make installDevGo' again" >&2
        exit 1
    fi
    eval "$(goenv init -)"

    goenv latest install -s
    goenv global $(goenv versions --bare | grep '^[0-9.]\+$' | sort -rV | head)
}

golang_version_func() {
    eval "$(goenv init -)"
    $1 version | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'goenv' setup_func_local setup_func_system version_func
eval "$(goenv init -)"
echo "${marker_info} Note that the latest release ${Bold}${Italic}go${Color_Off} ($(goenv latest --print) would be installed using pyenv"
main_script 'go' golang_install golang_install golang_version_func
