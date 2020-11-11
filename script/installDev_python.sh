#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install python environment${Color_Off}"

# if asdf is installed
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh

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
            rm -rf ${PYENV_ROOT} || true
            install='true'
        fi
    else
        install='true'
    fi

    if [ ${install} == 'true' ]; then
        curl https://pyenv.run | bash
        git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git \
            ${PYENV_ROOT}/plugins/pyenv-virtualenvwrapper
        git clone https://github.com/momo-lab/xxenv-latest.git \
            ${PYENV_ROOT}/plugins/xxenv-latest
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew list pyenv || brew install pyenv
        brew list pyenv-virtualenv || brew install pyenv-virtualenv
        brew list pyenv-virtualenvwrapper || brew install pyenv-virtualenvwrapper
        [ -d ${PYENV_ROOT}/plugins/xxenv-latest ] \
            || git clone https://github.com/momo-lab/xxenv-latest.git \
            ${PYENV_ROOT}/plugins/xxenv-latest

        if [ ${force} == 'true' ]; then
            brew upgrade pyenv
            brew upgrade pyenv-virtualenv
            brew upgrade pyenv-virtualenvwrapper
            rm -rf ${PYENV_ROOT}/plugins/xxenv-latest || true
            git clone https://github.com/momo-lab/xxenv-latest.git \
                ${PYENV_ROOT}/plugins/xxenv-latest
        fi
    else
        setup_func_local ${force}
    fi

}

version_func() {
    $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

python2_install() {
    version="$2"

    # prefer pyenv
    if command -v pyenv > /dev/null; then
        if [ -z ${version} ]; then
            echo "${marker_info} List of version"
            pyenv install --list | grep '^2' | grep -v 'dev'
            version=$(question "Choose python2 version to install", "latest")
        fi
        if [ ${version} == "latest" ]; then
            pyenv latest install -s 2
        else
            pyenv install ${version}
        fi
    elif command -v asdf > /dev/null; then
        asdf plugin-add python || true
        if [ -z ${version} ]; then
            echo "${marker_info} List of version"
            asdf list all python 2 | grep -v 'dev'
            version=$(question "Choose python2 version to install", "latest")
        fi
        if [ ${version} == "latest" ]; then
            asdf install python latest:2
        else
            asdf install python ${version}
        fi
    else
        echo "${marker_err} version managers are not found" >&2
        echo "${marker_err} Please install it first with 'make installDevPython or make installAsdf' again" >&2
        exit 1
    fi
}

python3_install() {
    version="$2"

    # prefer pyenv
    if command -v pyenv > /dev/null; then
        if [ -z ${version} ]; then
            echo "${marker_info} List of version"
            pyenv install --list | grep '^3' | grep -v 'dev'
            version=$(question "Choose python3 version to install", "latest")
        fi
        if [ ${version} == "latest" ]; then
            pyenv latest install -s 3
        else
            pyenv install ${version}
        fi
    elif command -v asdf > /dev/null; then
        asdf plugin-add python || true
        if [ -z ${version} ]; then
            echo "${marker_info} List of version"
            asdf list all python 3 | grep -v 'dev'
            version=$(question "Choose python3 version to install", "latest")
        fi
        if [ ${version} == "latest" ]; then
            asdf install python latest:3
        else
            asdf install python ${version}
        fi
    else
        echo "${marker_err} version managers are not found" >&2
        echo "${marker_err} Please install it first with 'make installDevPython' or 'make installDevAsdf' again" >&2
        exit 1
    fi
}

python_version_func() {
    $1 --version 2>&1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}



main_script 'pyenv' setup_func_local setup_func_system version_func
if command -v pyenv > /dev/null; then
    # install latest plugin if not installed
    [ ! -d ${PYENV_ROOT}/plugins/xxenv-latest ] && \
        git clone https://github.com/momo-lab/xxenv-latest.git ${PYENV_ROOT}/plugins/xxenv-latest
    eval "$(pyenv init -)"
    echo "${marker_info} Note that the latest release ${Bold}${Underline}python2${Color_Off} would be installed using ${Bold}${Underline}pyenv${Color_Off}"
    main_script 'python2' python2_install python2_install python_version_func
    echo "${marker_info} Note that the latest release ${Bold}${Underline}python3${Color_Off} would be installed using ${Bold}${Underline}pyenv${Color_Off}"
    main_script 'python3' python3_install python3_install python_version_func
    pyenv global | grep '[0-9.]' -q || pyenv global \
        $(pyenv versions | sed 's/[[:space:]]//g' | grep '^3' | sort -V -r | head -n 1) \
        $(pyenv versions | sed 's/[[:space:]]//g' | grep '^2' | sort -V -r | head -n 1)
else
    echo "${marker_info} Note that the latest release ${Bold}${Underline}python2${Color_Off} would be installed using ${Bold}${Underline}asdf${Color_Off}"
    main_script 'python2' python2_install python2_install python_version_func
    echo "${marker_info} Note that the latest release ${Bold}${Underline}python3${Color_Off} would be installed using ${Bold}${Underline}asdf${Color_Off}"
    main_script 'python3' python3_install python3_install python_version_func
    asdf current python >/dev/null 2>&1 || asdf global python \
        $(asdf list python | sed 's/[[:space:]]//g' | grep '^3' | sort -V -r | head -n 1) \
        $(asdf list python | sed 's/[[:space:]]//g' | grep '^2' | sort -V -r | head -n 1)
fi
