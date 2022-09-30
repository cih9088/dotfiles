#!/usr/bin/env bash

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${CUR_DIR}/../helpers/common.sh"

# install utils
"${CUR_DIR}/sh_shellcheck.sh"
"${CUR_DIR}/sh_shfmt.sh"
