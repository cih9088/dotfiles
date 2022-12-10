#!/usr/bin/env bash

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. "${CUR_DIR}/../helpers/common.sh"

# init environments
"${CUR_DIR}/python_virtualenv.sh"
"${CUR_DIR}/python_black.sh"
"${CUR_DIR}/python_isort.sh"
"${CUR_DIR}/python_flake8.sh"

(
  has asdf && asdf reshim python || true
  has pyenv && pyenv ++ rehash || true
) >&3 2>&4
