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
  && echo "${marker_info} Updating ${Bold}${Underline}dotfiles${Color_Off}..." \
  || start_spinner "Updating ${Bold}${Underline}dotfiles${Color_Off}..."
(
VIM_DIR=${PROJ_HOME}/vim
TMUX_DIR=${PROJ_HOME}/tmux
ZSH_DIR=${PROJ_HOME}/zsh
PYLINT_DIR=${PROJ_HOME}/pylint
CONFIG_DIR=${PROJ_HOME}/config

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

if [ -e $HOME/.config/nvim ]; then
  cp -RfL $HOME/.config/nvim ${backup_directory}/.config
  rm -rf $HOME/.config/nvim
fi
ln -s -f ${CONFIG_DIR}/nvim $HOME/.config/nvim

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

if [ -e $HOME/.config/spacebar ]; then
  cp -RfL $HOME/.config/spacebar ${backup_directory}/.config
  rm -rf $HOME/.config/spacebar
fi
ln -s -f ${CONFIG_DIR}/spacebar $HOME/.config/spacebar

if [ -e $HOME/.config/git ]; then
  cp -RfL $HOME/.config/git ${backup_directory}/.config
  rm -rf $HOME/.config/git
fi
ln -s -f ${CONFIG_DIR}/git $HOME/.config/git

if [ -e $HOME/.config/flake8 ]; then
  cp -RfL $HOME/.config/flake8 ${backup_directory}/.config
  rm -rf $HOME/.config/flake8
fi
ln -s -f ${CONFIG_DIR}/flake8 $HOME/.config/flake8

if [ -e $HOME/.config/pylintrc ]; then
  cp -RfL $HOME/.config/pylintrc ${backup_directory}/.config
  rm -rf $HOME/.config/pylintrc
fi
ln -s -f ${CONFIG_DIR}/pylintrc $HOME/.config/pylintrc

if [ -e $HOME/.config/fish ]; then
  cp -RfL $HOME/.config/fish ${backup_directory}/.config
  rm -rf $HOME/.config/fish
fi
ln -s -f ${CONFIG_DIR}/fish $HOME/.config/fish

if [ -e $HOME/.config/tealdeer ]; then
  cp -RfL $HOME/.config/tealdeer ${backup_directory}/.config
  rm -rf $HOME/.config/tealdeer
fi
ln -s -f ${CONFIG_DIR}/tealdeer $HOME/.config/tealdeer

if [ -e $HOME/.config/vivid ]; then
  cp -RfL $HOME/.config/vivid ${backup_directory}/.config
  rm -rf $HOME/.config/vivid
fi
ln -s -f ${CONFIG_DIR}/vivid $HOME/.config/vivid


# legacy configurations
if [ -e $HOME/.flake8 ]; then
  cp -RfL $HOME/.flake8 ${backup_directory}/.flake8
  rm -rf $HOME/.flake8
fi
if [ -e $HOME/.pylintrc ]; then
  cp -RfL $HOME/.pylintrc ${backup_directory}/.pylintrc
  rm -rf $HOME/.pylintrc
fi
if [ -e $HOME/.gitignore ]; then
  cp -RfL $HOME/.gitignore ${backup_directory}/.gitignore
  rm -rf $HOME/.gitignore
fi
if [ -e $HOME/.grip ]; then
  cp -RfL $HOME/.grip ${backup_directory}/.grip
  rm -rf $HOME/.grip
fi

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
  "${Bold}${Underline}dotfiles${Color_Off} are updated [local]" \
  "${Bold}${Underline}dotfiles${Color_Off} udpate is failed [local]. use VERBOSE=true for error message"

if [ -d ${backup_directory} ]; then
  echo "${marker_info} Your dotfiles have been backed up to ${backup_directory} "
fi
