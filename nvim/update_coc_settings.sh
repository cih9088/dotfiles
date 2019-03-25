#!/usr/bin/env bash

sed -i -e 's|"InterpreterPath": ".*"|"InterpreterPath": "'$(which python)'"|' ${HOME}/.config/nvim/coc-settings.json
