#!/usr/bin/env bash

sed -i 's|"InterpreterPath": ".*"|"InterpreterPath": "'$(which python)'"|' ${HOME}/.config/nvim/coc-settings.json
