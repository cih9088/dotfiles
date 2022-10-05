#!/usr/bin/env bash

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. "${CUR_DIR}/../helpers/common.sh"

# install utils
"${CUR_DIR}/python_black.sh"
"${CUR_DIR}/python_isort.sh"
"${CUR_DIR}/python_flake8.sh"

(
  has asdf && for plugin in $(asdf plugin list); do asdf reshim $plugin; done || true
  has pyenv && pyenv ++ rehash || true
) >&3 2>&4
