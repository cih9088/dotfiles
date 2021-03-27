#!/usr/bin/env bash

python_path=$(which python)
python_version="$(python -c 'import sys; print(sys.version.replace("\n", " "))' | awk '{printf $1}')"
python_search_path=$(python -c 'import sys; print(";".join(sys.path[1:]))')

# sed -i '' -e 's|"InterpreterPath": ".*"|"InterpreterPath": "'${python_path}'"|' ${HOME}/.config/nvim/coc-settings.json
# sed -i '' -e 's|"searchPath": \[.*|"searchPath": \[ "'"${python_search_path}"'" |' ${HOME}/.config/nvim/coc-settings.json
# sed -i '' -e 's|"Version": .*|"Version": "'${python_version}'",|' ${HOME}/.config/nvim/coc-settings.json

sed -i '' -e 's|"python.pythonPath": .*|"python.pythonPath": "'${python_path}'",|' ${HOME}/.config/nvim/coc-settings.json
