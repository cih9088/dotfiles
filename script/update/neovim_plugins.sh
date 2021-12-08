#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare to ${BOLD}${UNDERLINE}update ${THIS}${NC}"
################################################################

[[ ${VERBOSE} == "true" ]] &&
  log_info "Updating ${THIS_HL}..." ||
  start_spinner "Updating ${THIS_HL}..."
(
log_info "Update plugins"
# plugin update
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +PlugInstall +PlugUpgrade +PlugUpdate +qall

log_info "Install coc extensions"
## coc.nvim
# install coc extensions
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'CocInstall -sync coc-vimlsp coc-json coc-snippets coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-pyright coc-go coc-sh coc-highlight' +qall
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'CocUninstall -sync coc-python' +qall

# update coc extensions
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +CocUpdateSync +qall

# update remote plugins
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +UpdateRemotePlugins +qall

# install fzf in case of not installed automatically
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE +'call fzf#install()' +qall

rm -rf ${PROJ_HOME}/config/nvim/coc-settings.json || true
cp ${PROJ_HOME}/config/nvim/coc-settings-base.json ${PROJ_HOME}/config/nvim/coc-settings.json

# ln -snf ${PROJ_HOME}/vim/andy_lightline.vim ${HOME}/.local/share/nvim/plugged/lightline.vim/autoload/lightline/colorscheme
) >&3 2>&4 && exit_code="0" || exit_code="$?"
stop_spinner "${exit_code}" \
  "${THIS_HL} are updated [local]" \
  "${THIS_HL} udpate is failed [local]. use VERBOSE=true for error message"
