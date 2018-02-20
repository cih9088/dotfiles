#!/bin/bash

PROJ_HOME="$(pwd)"
if [ -d "${HOME}/dotfiles_old" ]; then
    echo "dotfiles_old folder already exists"
    exit
fi

# backup old files
\mkdir ~/dotfiles_old
\cp ~/.vimrc ~/dotfiles_old
\cp ~/.config/nvim/init.vim ~/dotfiles_old
\cp ~/.tmux.conf ~/dotfiles_old
\cp ~/.zshrc ~/dotfiles_old
\cp ~/.zpreztorc ~/dotfiles_old

# make directory if needed
if [ ! -d "~/.config/nvim" ]; then
    \mkdir -p ~/.config/nvim
fi

# Copy dot files
\ln -s -f ${PROJ_HOME}/vimrc ~/.vimrc
\ln -s -f ${PROJ_HOME}/vimrc ~/.config/nvim/init.vim
\ln -s -f ${PROJ_HOME}/tmux.conf ~/.tmux.conf
\ln -s -f ${PROJ_HOME}/tmux.conf.local ~/.tmux.conf.local
\ln -s -f ${PROJ_HOME}/zshrc ~/.zshrc
\ln -s -f ${PROJ_HOME}/zpreztorc ~/.zpreztorc
