#!/usr/bin/env bash

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${CUR_DIR}/../helpers/common.sh"

# install utils
"${CUR_DIR}/python_black.sh"
"${CUR_DIR}/python_isort.sh"
"${CUR_DIR}/python_flake8.sh"
