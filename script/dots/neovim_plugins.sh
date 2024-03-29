#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"

has -v npm pip
################################################################

setup_for_local() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    log_error "Not supported command 'remove'"
    exit 1
  elif [ "${COMMAND}" == "install" ] || [ "${COMMAND}" == "update" ]; then
    if [ ! -f "${HOME}/.config/nvim/init.vim" ]; then
      log_error "${HOME}/.config/nvim/init.vim not found"
      exit 1
    fi

    ## plugin
    log_info "Install plugin manager"
    nvim --headless +PlugUpgrade +qall
    log_info "Install plugins"
    nvim --headless +"set nonumber" +"PlugInstall --sync" +%print +UpdateRemotePlugins +qall
    log_info "Update plugins"
    nvim --headless +"set nonumber" +"PlugUpdate  --sync" +%print +UpdateRemotePlugins +qall

    ## treesitter
    log_info "Install Treesitter parsers"
    nvim --headless +'if has_key(g:plugs, "nvim-treesitter") '`
      `'| execute "TSInstallSync all" '`
      `'| execute "TSUpdateSync all"'`
      `'| endif' +qall

    ## coc.nvim
    log_info "Install coc extensions"
    # install coc extensions
    nvim --headless +'if has_key(g:plugs, "coc.nvim") | '`
      `'execute "CocInstall -sync coc-vimlsp coc-json coc-snippets coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-pyright coc-go coc-sh coc-highlight" '`
      `'| execute "CocUninstall -sync coc-python" '`
      `'| execute "CocUpdateSync" '`
      `'| endif' +qall
    nvim --headless +'if has_key(g:plugs, "coc.nvim") '`
      `'| endif' +qall
    # update remote plugins
    nvim --headless +UpdateRemotePlugins +qall
    # update coc-settings.json
    rm -rf "${PROJ_HOME}/config/nvim/coc-settings.json" || true
    cp "${PROJ_HOME}/config/nvim/coc-settings-base.json" "${PROJ_HOME}/config/nvim/coc-settings.json"

    ## fzf
    log_info "Install fzf"
    nvim --headless +'if has_key(g:plugs, "fzf") | call fzf#install() | endif' +qall

    # will be installed automatically
    # ## mason
    # log_info "Install LSPs"
    # nvim --headless +'if has_key(g:plugs, "mason.nvim") '`
    #   `'| execute "MasonInstall pyright gopls rust-analyzer bash-language-server vim-language-server yaml-language-server json-lsp lua-language-server ansible-language-server typescript-language-server cmake-language-server" '`
    #   `'| execute "MasonInstall isort black ruff debugpy shfmt prettier node-debug2-adapter codelldb delve" '`
    #   `'| endif' +qall || true
  fi
}

main_script "${THIS}" \
  setup_for_local ""
