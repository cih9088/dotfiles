#!/bin/bash

if [ -d "${HOME}/dotfiles_old" ]; then
    echo "dotfiles_old folder already exists"
    exit
fi

PROJ_HOME="$(dirname "$(pwd)")"
VIM_DIR=${PROJ_HOME}/vim
NVIM_DIR=${PROJ_HOME}/nvim
TMUX_DIR=${PROJ_HOME}/tmux
ZSH_DIR=${PROJ_HOME}/zsh
PYLINT_DIR=${PROJ_HOME}/pylint

# backup old files
\mkdir ~/dotfiles_old
\cp ~/.vimrc ~/dotfiles_old
\cp -r ~/.vim ~/dotfiles_old

\cp -r ~/.config/nvim/ ~/dotfiles_old

\cp -r ~/.tmux ~/dotfiles_old
\cp ~/.tmux.conf ~/dotfiles_old

\cp ~/.zshrc ~/dotfiles_old
\cp ~/.zpreztorc ~/dotfiles_old

\cp ~/.pylintrc ~/dotfiles_old

# make directory if needed
if [ ! -d "~/.config" ]; then
    \mkdir -p ~/.config
fi

# Copy dot files
\ln -s -f ${VIM_DIR} ~/.vim
\ln -s -f ${VIM_DIR}/vimrc ~/.vimrc

\ln -s -f ${NVIM_DIR} ~/.config/nvim

\ln -s -f ${TMUX_DIR} ~/.tmux
\ln -s -f ${TMUX_DIR}/tmux.conf ~/.tmux.conf

\ln -s -f ${ZSH_DIR}/zshrc ~/.zshrc
\ln -s -f ${ZSH_DIR}/zpreztorc ~/.zpreztorc

\ln -s -f ${PYLINT_DIR}/pylintrc ~/.pylintrc
