#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install python environment${Color_Off}"

# use sytem python
export PYENV_ROOT=${HOME}/.pyenv

export PATH="${HOME}/.pyenv/bin:$PATH"
################################################################

setup_func_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -x "$(command -v ${PYENV_ROOT}bin/pyenv)" ]; then
        if [ ${force} == 'true' ]; then
            install='true'
        fi
    else
        install='true'
    fi

    if [ ${install} == 'true' ]; then
        rm -rf ${PYENV_ROOT} || true
        curl https://pyenv.run | bash
        git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${PYENV_ROOT}/plugins/pyenv-virtualenvwrapper
        git clone https://github.com/momo-lab/xxenv-latest.git ${PYENV_ROOT}/plugins/xxenv-latest
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        if [ -x "$(command -v /usr/local/bin/pyenv)" ]; then
            if [ ${force} == 'true' ]; then
                brew upgrade pyenv
                brew upgrade pyenv-virtualenv
                brew upgrade pyenv-virtualenvwrapper
                rm -rf ${PYENV_ROOT}/plugins/xxenv-latest || true
                git clone https://github.com/momo-lab/xxenv-latest.git ${PYENV_ROOT}/plugins/xxenv-latest
            fi
        else
            brew install pyenv
            brew install pyenv-virtualenv
            brew install pyenv-virtualenvwrapper
            git clone https://github.com/momo-lab/xxenv-latest.git ${PYENV_ROOT}/plugins/xxenv-latest
        fi
    else
        setup_func_local ${force}
    fi

}

version_func() {
    $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

python2_install() {
    if ! command -v pyenv > /dev/null; then
        echo "${marker_err} pyenv is not found" >&2
        echo "${marker_err} Please install pyenv first with 'make installDevPython' again" >&2
        exit 1
    fi
    eval "$(pyenv init -)"

    pyenv latest install -s 2
}

python3_install() {
    if ! command -v pyenv > /dev/null; then
        echo "${marker_err} pyenv is not found" >&2
        echo "${marker_err} Please install pyenv first with 'make installDevPython' again" >&2
        exit 1
    fi
    eval "$(pyenv init -)"

    pyenv latest install -s 3
}

python_version_func() {
    eval "$(pyenv init -)"
    $1 --version 2>&1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'pyenv' setup_func_local setup_func_system version_func
echo "${marker_info} Note that the latest release version of ${Bold}${Italic}python2${Color_Off} would be installed using pyenv"
main_script 'python2' python2_install python2_install python_version_func
echo "${marker_info} Note that the latest release version of ${Bold}${Italic}python3${Color_Off} would be installed using pyenv"
main_script 'python3' python3_install python3_install python_version_func
