#!/bin/bash

echo '[*] Copying dot files....'

################################################################
set -e

case "$OSTYPE" in
    solaris*) platform='SOLARIS' ;;
    darwin*)  platform='OSX' ;;
    linux*)   platform='LINUX' ;;
    bsd*)     platform='BSD' ;;
    msys*)    platform='WINDOWS' ;;
    *)        platform='unknown: $OSTYPE' ;;
esac

if [[ $$ = $BASHPID ]]; then
    if [[ $platform == "OSX" ]]; then
        PROJ_HOME=$(cd $(echo $(dirname $0) | xargs greadlink -f ); cd ..; pwd)
    elif [[ $platform == "LINUX" ]]; then
        PROJ_HOME=$(cd $(echo $(dirname $0) | xargs readlink -f ); cd ..; pwd)
    fi
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
    mv $HOME/.vimrc $HOME/dotfiles_old
fi
ln -s -f ${VIM_DIR}/vimrc $HOME/.vimrc

if [ -e $HOME/.vim ]; then
    mv $HOME/.vim $HOME/dotfiles_old
fi
ln -s -f ${VIM_DIR} $HOME/.vim

if [ -e $HOME/.config/nvim ]; then
    mv $HOME/.config/nvim $HOME/dotfiles_old
fi
ln -s -f ${NVIM_DIR} $HOME/.config/nvim

if [ -e $HOME/.tmux ]; then
    mv $HOME/.tmux $HOME/dotfiles_old
fi
ln -s -f ${TMUX_DIR} $HOME/.tmux

if [ -e $HOME/.tmux.conf ]; then
    mv $HOME/.tmux.conf $HOME/dotfiles_old
fi
ln -s -f ${TMUX_DIR}/tmux.conf $HOME/.tmux.conf

if [ -e $HOME/.zshrc ]; then
    mv $HOME/.zshrc $HOME/dotfiles_old
fi
ln -s -f ${ZSH_DIR}/zshrc $HOME/.zshrc

if [ -e $HOME/.zpreztorc ]; then
    mv $HOME/.zpreztorc $HOME/dotfiles_old
fi
ln -s -f ${ZSH_DIR}/zpreztorc $HOME/.zpreztorc

if [ -e $HOME/.zshenv ]; then
    mv $HOME/.zshenv $HOME/dotfiles_old
fi
ln -s -f ${ZSH_DIR}/zshenv $HOME/.zshenv

if [ -e $HOME/.pylintrc ]; then
    mv $HOME/.pylintrc $HOME/dotfiles_old
fi
ln -s -f ${PYLINT_DIR}/pylintrc $HOME/.pylintrc
