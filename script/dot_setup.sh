#!/bin/bash

echo '[*] Copying dot files....'

################################################################
set -e

case "$OSTYPE" in
    solaris*) platform="SOLARIS" ;;
    darwin*)  platform="OSX" ;;
    linux*)   platform="LINUX" ;;
    bsd*)     platform="BSD" ;;
    msys*)    platform="WINDOWS" ;;
    *)        platform="unknown: $OSTYPE" ;;
esac

if [[ $$ = $BASHPID ]]; then
    PROJ_HOME=$(git rev-parse --show-toplevel)
fi

if [ -d "${HOME}/dotfiles_old" ]; then
    echo "[*] dotfiles_old folder already exists"
    echo "[*] Rename it to 'dotfiles_old_old'"
    mv $HOME/dotfiles_old $HOME/dotfiles_old_old
    mkdir -p ~/dotfiles_old
else
    mkdir -p ~/dotfiles_old
fi

if [ ! -d "~/.config" ]; then
    mkdir -p ~/.config
fi

VIM_DIR=${PROJ_HOME}/vim
NVIM_DIR=${PROJ_HOME}/nvim
TMUX_DIR=${PROJ_HOME}/tmux
ZSH_DIR=${PROJ_HOME}/zsh
PYLINT_DIR=${PROJ_HOME}/pylint

# backup old files and replace it with mine
if [ -e $HOME/.vimrc ]; then
    cp -RfH $HOME/.vimrc $HOME/dotfiles_old
    rm -rf $HOME/.vimrc
fi
ln -s -f ${VIM_DIR}/vimrc $HOME/.vimrc

if [ -e $HOME/.vim ]; then
    cp -RfH $HOME/.vim $HOME/dotfiles_old
    rm -rf $HOME/.vim
fi
ln -s -f ${VIM_DIR} $HOME/.vim

if [ -e $HOME/.config/nvim ]; then
    cp -RfH $HOME/.config/nvim $HOME/dotfiles_old
    rm -rf $HOME/.config/nvim
fi
ln -s -f ${NVIM_DIR} $HOME/.config/nvim

if [ -e $HOME/.tmux ]; then
    cp -RfH $HOME/.tmux $HOME/dotfiles_old
    rm -rf $HOME/.tmux
fi
ln -s -f ${TMUX_DIR} $HOME/.tmux

if [ -e $HOME/.tmux.conf ]; then
    cp -RfH $HOME/.tmux.conf $HOME/dotfiles_old
    rm -rf $HOME/.tmux.conf
fi
ln -s -f ${TMUX_DIR}/tmux.conf $HOME/.tmux.conf

if [ -e $HOME/.zshrc ]; then
    cp -RfH $HOME/.zshrc $HOME/dotfiles_old
    rm -rf $HOME/.zshrc
fi
ln -s -f ${ZSH_DIR}/zshrc $HOME/.zshrc

if [ -e $HOME/.zpreztorc ]; then
    cp -RfH $HOME/.zpreztorc $HOME/dotfiles_old
    rm -rf $HOME/.zpreztorc
fi
ln -s -f ${ZSH_DIR}/zpreztorc $HOME/.zpreztorc

if [ -e $HOME/.zshenv ]; then
    cp -RfH $HOME/.zshenv $HOME/dotfiles_old
    rm -rf $HOME/.zshenv
fi
ln -s -f ${ZSH_DIR}/zshenv $HOME/.zshenv

if [ -e $HOME/.zprofile ]; then
    cp -RfH $HOME/.zprofile $HOME/dotfiles_old
    rm -rf $HOME/.zprofile
fi
ln -s -f ${ZSH_DIR}/zprofile $HOME/.zprofile

if [ -e $HOME/.pylintrc ]; then
    cp -RfH $HOME/.pylintrc $HOME/dotfiles_old
    rm -rf $HOME/.pylintrc
fi
ln -s -f ${PYLINT_DIR}/pylintrc $HOME/.pylintrc

# clean up dotfiles old if there is nothing backuped
if [ -z "$(ls -A $HOME/dotfiles_old)" ]; then
    rm -rf $HOME/doefiles_old
fi
