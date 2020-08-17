#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}update dotfiles${Color_Off}"
################################################################

backup_directory=${HOME}/dotfiles.$(date "+%y%m%d%H%M").$(random-string 6).bak
mkdir -p ${backup_directory}

[[ ${VERBOSE} == "true" ]] \
    && echo "${marker_info} Updating dotfiles..." \
    || start_spinner "Updating dotfiles..."
(
VIM_DIR=${PROJ_HOME}/vim
NVIM_DIR=${PROJ_HOME}/nvim
TMUX_DIR=${PROJ_HOME}/tmux
ZSH_DIR=${PROJ_HOME}/zsh
PYLINT_DIR=${PROJ_HOME}/pylint
CONFIG_DIR=${PROJ_HOME}/config
GRIP_DIR=${PROJ_HOME}/grip
GIT_DIR=${PROJ_HOME}/git

# backup old files and replace it with mine
if [ -e $HOME/.vimrc ]; then
    cp -RfL $HOME/.vimrc ${backup_directory}
    rm -rf $HOME/.vimrc
fi
ln -s -f ${VIM_DIR}/vimrc $HOME/.vimrc

if [ -e $HOME/.vim ]; then
    cp -RfL $HOME/.vim ${backup_directory}
    rm -rf $HOME/.vim
fi
ln -s -f ${VIM_DIR} $HOME/.vim

if [ -e $HOME/.config/nvim ]; then
    cp -RfL $HOME/.config/nvim ${backup_directory}/.config
    rm -rf $HOME/.config/nvim
fi
ln -s -f ${NVIM_DIR} $HOME/.config/nvim

if [ -e $HOME/.tmux ]; then
    cp -RfH $HOME/.tmux ${backup_directory}
    rm -rf $HOME/.tmux
fi
ln -s -f ${TMUX_DIR} $HOME/.tmux

if [ -e $HOME/.tmux.conf ]; then
    cp -RfL $HOME/.tmux.conf ${backup_directory}
    rm -rf $HOME/.tmux.conf
fi
ln -s -f ${TMUX_DIR}/tmux.conf $HOME/.tmux.conf

if [ -e $HOME/.zshrc ]; then
    cp -RfL $HOME/.zshrc ${backup_directory}
    rm -rf $HOME/.zshrc
fi
ln -s -f ${ZSH_DIR}/zshrc $HOME/.zshrc

if [ -e $HOME/.zpreztorc ]; then
    cp -RfL $HOME/.zpreztorc ${backup_directory}
    rm -rf $HOME/.zpreztorc
fi
ln -s -f ${ZSH_DIR}/zpreztorc $HOME/.zpreztorc

if [ -e $HOME/.zshenv ]; then
    cp -RfL $HOME/.zshenv ${backup_directory}
    rm -rf $HOME/.zshenv
fi
ln -s -f ${ZSH_DIR}/zshenv $HOME/.zshenv

if [ -e $HOME/.zprofile ]; then
    cp -RfL $HOME/.zprofile ${backup_directory}
    rm -rf $HOME/.zprofile
fi
ln -s -f ${ZSH_DIR}/zprofile $HOME/.zprofile

if [ -e $HOME/.zlogout ]; then
    cp -RfL $HOME/.zlogout ${backup_directory}
    rm -rf $HOME/.zlogout
fi
ln -s -f ${ZSH_DIR}/zlogout $HOME/.zlogout

if [ -e $HOME/.pylintrc ]; then
    cp -RfL $HOME/.pylintrc ${backup_directory}
    rm -rf $HOME/.pylintrc
fi
ln -s -f ${PYLINT_DIR}/pylintrc $HOME/.pylintrc

if [ -e $HOME/.grip ]; then
    cp -RfL $HOME/.grip ${backup_directory}
    rm -rf $HOME/.grip
fi
ln -s -f ${GRIP_DIR} $HOME/.grip

if [ -e $HOME/.config/alacritty ]; then
    cp -RfL $HOME/.config/alacritty ${backup_directory}/.config
    rm -rf $HOME/.config/alacritty
fi
ln -s -f ${CONFIG_DIR}/alacritty $HOME/.config/alacritty

if [ -e $HOME/.config/yabai ]; then
    cp -RfL $HOME/.config/yabai ${backup_directory}/.config
    rm -rf $HOME/.config/yabai
fi
ln -s -f ${CONFIG_DIR}/yabai $HOME/.config/yabai

if [ -e $HOME/.config/skhd ]; then
    cp -RfL $HOME/.config/skhd ${backup_directory}/.config
    rm -rf $HOME/.config/skhd
fi
ln -s -f ${CONFIG_DIR}/skhd $HOME/.config/skhd

if [ -e $HOME/.gitignore ]; then
    cp -RfL $HOME/.gitignore ${backup_directory}/.gitignore
    rm -rf $HOME/.gitignore
fi
ln -s -f ${GIT_DIR}/gitignore $HOME/.gitignore

# clean up dotfiles old if there is nothing backuped
if [ -z "$(ls -A ${backup_directory})" ]; then
    rm -rf ${backup_directory}
fi

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi

) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "dotfiles are updated [local]" \
    "dotfiles udpate is failed [local]. use VERBOSE=true for error message"

if [ -d ${backup_directory} ]; then
    echo "${marker_info} Your dotfiles have been backed up to ${backup_directory} "
fi
