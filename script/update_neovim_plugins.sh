#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update neovim plugin${Color_Off}"

export PATH="${HOME}/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
export PATH="${HOME}/.goenv/bin:$PATH"
eval "$(goenv init -)"
export PATH="${HOME}/.local/bin:$PATH"
################################################################

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating ${Bold}${Underline}neovim plugins${Color_Off}..." \
    || start_spinner "Updating ${Bold}${Underline}neovim plugins${Color_Off}..."
(

# plugin update
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +PlugInstall +PlugUpgrade +PlugUpdate +UpdateRemotePlugins +qall

# install coc extensions
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'CocInstall -sync coc-json coc-snippets coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-python coc-go coc-sh' +qall
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +CocUpdateSync +qall

# ln -snf ${PROJ_HOME}/vim/andy_lightline.vim ${HOME}/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "${Bold}${Underline}neovim plugins${Color_Off} are updated [local]" \
    "${Bold}${Underline}neovim plugins${Color_Off} udpate is failed [local]. use VERBOSE=true for error message"
