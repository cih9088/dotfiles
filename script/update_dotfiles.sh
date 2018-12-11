#!/bin/bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
if [ -d "${HOME}/dotfiles_old" ]; then
    echo "${marker_err} dotfiles_old folder already exists"
    echo "${marker_info} Rename it to 'dotfiles_old_old'"
    rm -rf $HOME/dotfiles_old_old || true
    mv $HOME/dotfiles_old $HOME/dotfiles_old_old
    mkdir -p ~/dotfiles_old
    mkdir -p ~/dotfiles_old/.config
else
    mkdir -p ~/dotfiles_old
    mkdir -p ~/dotfiles_old/.config
fi

[[ ${VERBOSE} == YES ]] || start_spinner "Updating dotfiles..."
(
VIM_DIR=${PROJ_HOME}/vim
NVIM_DIR=${PROJ_HOME}/nvim
TMUX_DIR=${PROJ_HOME}/tmux
ZSH_DIR=${PROJ_HOME}/zsh
PYLINT_DIR=${PROJ_HOME}/pylint
CONFIG_DIR=${PROJ_HOME}/config
GRIP_DIR=${PROJ_HOME}/grip

# backup old files and replace it with mine
if [ -e $HOME/.vimrc ]; then
    cp -RfL $HOME/.vimrc $HOME/dotfiles_old
    rm -rf $HOME/.vimrc
fi
ln -s -f ${VIM_DIR}/vimrc $HOME/.vimrc

if [ -e $HOME/.vim ]; then
    cp -RfL $HOME/.vim $HOME/dotfiles_old
    rm -rf $HOME/.vim
fi
ln -s -f ${VIM_DIR} $HOME/.vim

if [ -e $HOME/.config/nvim ]; then
    cp -RfL $HOME/.config/nvim $HOME/dotfiles_old/.config
    rm -rf $HOME/.config/nvim
fi
ln -s -f ${NVIM_DIR} $HOME/.config/nvim

if [ -e $HOME/.tmux ]; then
    cp -RfH $HOME/.tmux $HOME/dotfiles_old
    rm -rf $HOME/.tmux
fi
ln -s -f ${TMUX_DIR} $HOME/.tmux

if [ -e $HOME/.tmux.conf ]; then
    cp -RfL $HOME/.tmux.conf $HOME/dotfiles_old
    rm -rf $HOME/.tmux.conf
fi
ln -s -f ${TMUX_DIR}/tmux.conf $HOME/.tmux.conf

if [ -e $HOME/.zshrc ]; then
    cp -RfL $HOME/.zshrc $HOME/dotfiles_old
    rm -rf $HOME/.zshrc
fi
ln -s -f ${ZSH_DIR}/zshrc $HOME/.zshrc

if [ -e $HOME/.zpreztorc ]; then
    cp -RfL $HOME/.zpreztorc $HOME/dotfiles_old
    rm -rf $HOME/.zpreztorc
fi
ln -s -f ${ZSH_DIR}/zpreztorc $HOME/.zpreztorc

if [ -e $HOME/.zshenv ]; then
    cp -RfL $HOME/.zshenv $HOME/dotfiles_old
    rm -rf $HOME/.zshenv
fi
ln -s -f ${ZSH_DIR}/zshenv $HOME/.zshenv

if [ -e $HOME/.zprofile ]; then
    cp -RfL $HOME/.zprofile $HOME/dotfiles_old
    rm -rf $HOME/.zprofile
fi
ln -s -f ${ZSH_DIR}/zprofile $HOME/.zprofile

if [ -e $HOME/.pylintrc ]; then
    cp -RfL $HOME/.pylintrc $HOME/dotfiles_old
    rm -rf $HOME/.pylintrc
fi
ln -s -f ${PYLINT_DIR}/pylintrc $HOME/.pylintrc

if [ -e $HOME/.grip ]; then
    cp -RfL $HOME/.grip $HOME/dotfiles_old
    rm -rf $HOME/.grip
fi
ln -s -f ${GRIP_DIR} $HOME/.grip

if [ -e $HOME/.config/alacritty ]; then
    cp -RfL $HOME/.config/alacritty $HOME/dotfiles_old/.config
    rm -rf $HOME/.config/alacritty
fi
ln -s -f ${CONFIG_DIR}/alacritty $HOME/.config/alacritty

# clean up dotfiles old if there is nothing backuped
if [ -z "$(ls -A $HOME/dotfiles_old)" ]; then
    rm -rf $HOME/doefiles_old
fi

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi

) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "dotfiles are updated [local]" \
    "dotfiles udpate is failed [local]. use VERBOSE=YES for error message"
