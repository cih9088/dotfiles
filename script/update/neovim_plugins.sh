#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare to ${BOLD}${UNDERLINE}update ${THIS}${NC}"
################################################################

[[ ${VERBOSE} == "true" ]] &&
  log_info "Updating ${THIS_HL}..." ||
  start_spinner "Updating ${THIS_HL}..."
(
## plugin
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +PlugUpgrade +qall
log_info "Install plugins"
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'PlugInstall --sync' +%print +qall
log_info "Update plugins"
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'PlugUpdate --sync' +%print +qall

## coc.nvim
log_info "Install coc extensions"
# install coc extensions
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'if has_key(g:plugs, "coc.nvim") | execute "CocInstall -sync coc-vimlsp coc-json coc-snippets coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-pyright coc-go coc-sh coc-highlight" | endif' +qall
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'if has_key(g:plugs, "coc.nvim") | execute "CocUninstall -sync coc-python" | endif' +qall
# update coc extensions
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'if has_key(g:plugs, "coc.nvim") | execute "CocUpdateSync" | endif' +qall
# update remote plugins
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +UpdateRemotePlugins +qall
# update coc-settings.json
rm -rf "${PROJ_HOME}/config/nvim/coc-settings.json" || true
cp "${PROJ_HOME}/config/nvim/coc-settings-base.json" "${PROJ_HOME}/config/nvim/coc-settings.json"


## fzf
log_info "Install fzf"
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'if has_key(g:plugs, "fzf") | call fzf#install() | endif' +qall

## treesitter
log_info "Install Treesitter parsers"
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'if has_key(g:plugs, "nvim-treesitter") | execute "TSInstallSync all" | endif' +qall
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'if has_key(g:plugs, "nvim-treesitter") | execute "TSUpdateSync all" | endif' +qall

# ln -snf ${PROJ_HOME}/vim/andy_lightline.vim ${HOME}/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme
) >&3 2>&4 && exit_code="0" || exit_code="$?"
stop_spinner "${exit_code}" \
  "${THIS_HL} are updated [local]" \
  "${THIS_HL} udpate is failed [local]. use VERBOSE=true for error message"
