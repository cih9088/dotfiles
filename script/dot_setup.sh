#!/bin/bash

set -e

if [ -d "${HOME}/dotfiles_old" ]; then
    echo "dotfiles_old folder already exists"
    echo "rename it to 'dotfiles_old_old'"
    mv $HOME/dotfiles_old $HOME/dotfiles_old_old
    mkdir -p ~/dotfiles_old
fi

if [ ! -d "~/.config" ]; then
    mkdir -p ~/.config
fi

PROJ_HOME="$(dirname "$(pwd)")"
VIM_DIR=${PROJ_HOME}/vim
NVIM_DIR=${PROJ_HOME}/nvim
TMUX_DIR=${PROJ_HOME}/tmux
ZSH_DIR=${PROJ_HOME}/zsh
PYLINT_DIR=${PROJ_HOME}/pylint

# backup old files and replace it with mine
if [ -e ~/.vimrc ]; then
    mv ~/.vimrc ~/dotfiles_old
fi
ln -s -f ${VIM_DIR} ~/.vim

if [ -e ~/.vim ]; then
    mv ~/.vim ~/dotfiles_old
fi
ln -s -f ${VIM_DIR}/vimrc ~/.vimrc

if [ -e ~/.config/nvim ]; then
    mv ~/.config/nvim/ ~/dotfiles_old
fi
ln -s -f ${NVIM_DIR} ~/.config/nvim

if [ -e ~/.tmux ]; then
    mv ~/.tmux ~/dotfiles_old
fi
ln -s -f ${TMUX_DIR} ~/.tmux

if [ -e ~/.tmux.conf ]; then
    mv ~/.tmux.conf ~/dotfiles_old
fi
ln -s -f ${TMUX_DIR}/tmux.conf ~/.tmux.conf

if [ -e ~/.zshrc ]; then
    mv ~/.zshrc ~/dotfiles_old
fi
ln -s -f ${ZSH_DIR}/zshrc ~/.zshrc

if [ -e ~/.zpreztorc ]; then
    mv ~/.zpreztorc ~/dotfiles_old
fi
ln -s -f ${ZSH_DIR}/zpreztorc ~/.zpreztorc

if [ -e ~/.pylintrc ]; then
    mv ~/.pylintrc ~/dotfiles_old
fi
ln -s -f ${PYLINT_DIR}/pylintrc ~/.pylintrc
