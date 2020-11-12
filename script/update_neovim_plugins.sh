#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update neovim plugin${Color_Off}"

export PATH="${HOME}/.pyenv/bin:$PATH"
export PATH="${HOME}/.goenv/bin:$PATH"
export PATH="${HOME}/.local/bin:$PATH"

# if asdf is installed
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true
command -v goenv > /dev/null && eval "$(goenv init -)" || true
################################################################

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating ${Bold}${Underline}neovim plugins${Color_Off}..." \
    || start_spinner "Updating ${Bold}${Underline}neovim plugins${Color_Off}..."
(

# plugin update
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +PlugInstall +PlugUpgrade +PlugUpdate +qall

## coc.nvim
# install coc extensions
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'CocInstall -sync coc-vimlsp coc-json coc-snippets coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-pyright coc-go coc-sh coc-highlight' +qall
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'CocUninstall -sync coc-python' +qall

# update coc extensions
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +CocUpdateSync +qall

# update remote plugins
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +UpdateRemotePlugins +qall

rm -rf ${PROJ_HOME}/nvim/coc-settings.json || true
cp ${PROJ_HOME}/nvim/coc-settings-base.json ${PROJ_HOME}/nvim/coc-settings.json

# ln -snf ${PROJ_HOME}/vim/andy_lightline.vim ${HOME}/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "${Bold}${Underline}neovim plugins${Color_Off} are updated [local]" \
    "${Bold}${Underline}neovim plugins${Color_Off} udpate is failed [local]. use VERBOSE=true for error message"
