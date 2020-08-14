#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to update neovim plugin"

export PATH="${HOME}/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
export PATH="${HOME}/.goenv/bin:$PATH"
eval "$(goenv init -)"
goenv global $(goenv versions --bare | grep '^[0-9.]\+$' | sort -rV | head)
################################################################

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating neovim plugins..." \
    || start_spinner "Updating neovim plugins..."
(

# plugin update
# nvim -E -s -u "${HOME}/.config/nvim/init.vim" +PlugInstall +PlugUpgrade +PlugUpdate +UpdateRemotePlugins +qall || true

# plugin update
nvim +PlugInstall +PlugUpgrade +PlugUpdate +UpdateRemotePlugins +qall

# install coc extensions
nvim +'CocInstall -sync coc-json coc-snippets coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-python coc-go coc-sh' +qall
nvim +CocUpdateSync +qall

# ln -snf ${PROJ_HOME}/vim/andy_lightline.vim ${HOME}/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme
) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "neovim plugins are updated [local]" \
    "neovim plugins udpate is failed [local]. use VERBOSE=true for error message"
