#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_info} Install python dev"
(
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
) >&3 2>&4 \
    && echo -e "\033[2K \033[100D${marker_ok} python dev is installed [$1]" \
    || echo -e "\033[2K \033[100D${marker_err} python dev install is failed [$1]. use VERBOSE=YES for error message" &
[[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing python dev..."
