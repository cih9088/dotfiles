#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing python dev..."
(

    if [[ $1 = local ]]; then
        curl https://pyenv.run | bash
        git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${HOME}/andy/.pyenv/plugins/pyenv-virtualenvwrapper
    else
        if [[ $platform == "OSX" ]]; then
            # brew install shellcheck
            brew bundle --file=- <<EOS
brew 'pyenv'
brew 'pyenv-virtualenv'
brew 'pyenv-virtualenvwrapper'
EOS
        elif [[ $platform == "LINUX" ]]; then
            echo "${marker_err} Not available on OSX"
            exit 1
        fi
    fi

    pip install glances --user
    pip install grip --user
    pip install gpustat --user
    pip install ipdb --user
    pip install pudb --user
    pip install pylint --user
    pip install pylint-venv --user
    pip install jedi --user
    pip install 'python-language-server[all]' --user
    pip install virtualenv --user
    pip install virtualenvwrapper --user
    pip3 install virtualenv --user
    pip3 install virtualenvwrapper --user
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "python dev is installed [local]" \
    "python dev install is failed [local]. use VERBOSE=YES for error message"

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
