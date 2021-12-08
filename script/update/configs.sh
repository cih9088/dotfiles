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


_BACKUP_PATH="${HOME}/dotfiles.$(date '+%y%m%d%H%M%S').bak"
mkdir -p ${_BACKUP_PATH}

[[ ${VERBOSE} == "true" ]] &&
  log_info "Updating ${THIS_HL}..." \
  || start_spinner "Updating ${THIS_HL}..."
(
CONFIG_DIR=${PROJ_HOME}/config
VIM_DIR=${CONFIG_DIR}/vim
ZSH_DIR=${CONFIG_DIR}/zsh
TMUX_DIR=${CONFIG_DIR}/tmux

# legacy configurations to remove broken configs
[ ! -e $HOME/.flake8 ] && rm -rf $HOME/.flake8
[ ! -e $HOME/.pylintrc ] && rm -rf $HOME/.pylintrc
[ ! -e $HOME/.gitignore ] && rm -rf $HOME/.gitignore
[ ! -e $HOME/.grip ] && rm -rf $HOME/.grip

# backup old files and replace it with mine
backup-and-link "${CONFIG_DIR}/nvim"                   "$HOME/.config/nvim"      "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/alacritty"              "$HOME/.config/alacritty" "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/iterm2"                 "$HOME/.config/iterm2"    "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/yabai"                  "$HOME/.config/yabai"     "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/skhd"                   "$HOME/.config/skhd"      "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/bitbar"                 "$HOME/.config/bitbar"    "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/spacebar"               "$HOME/.config/spacebar"  "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/swiftbar"               "$HOME/.config/swiftbar"  "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/git"                    "$HOME/.config/git"       "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/flake8"                 "$HOME/.config/flake8"    "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/pylintrc"               "$HOME/.config/pylintrc"  "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/fish"                   "$HOME/.config/fish"      "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/tealdeer"               "$HOME/.config/tealdeer"  "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/vivid"                  "$HOME/.config/vivid"     "$_BACKUP_PATH"

backup-and-link "${CONFIG_DIR}/simplebar"              "$HOME/.config/simplebar" "$_BACKUP_PATH"
backup-and-link "${CONFIG_DIR}/simplebar/.simplebarrc" "$HOME/.simplebarrc"      "$_BACKUP_PATH"

backup-and-link "${VIM_DIR}"                           "$HOME/.vim"              "$_BACKUP_PATH"
backup-and-link "${VIM_DIR}/vimrc"                     "$HOME/.vimrc"            "$_BACKUP_PATH"

backup-and-link "${TMUX_DIR}"                          "$HOME/.tmux"             "$_BACKUP_PATH"
backup-and-link "${TMUX_DIR}/tmux.conf"                "$HOME/.tmux.conf"        "$_BACKUP_PATH"

backup-and-link "${ZSH_DIR}/zshrc"                     "$HOME/.zshrc"            "$_BACKUP_PATH"
backup-and-link "${ZSH_DIR}/zpreztorc"                 "$HOME/.zpreztorc"        "$_BACKUP_PATH"
backup-and-link "${ZSH_DIR}/zshenv"                    "$HOME/.zshenv"           "$_BACKUP_PATH"
backup-and-link "${ZSH_DIR}/zprofile"                  "$HOME/.zprofile"         "$_BACKUP_PATH"
backup-and-link "${ZSH_DIR}/zlogout"                   "$HOME/.zlogout"          "$_BACKUP_PATH"

# clean up dotfiles old if there is nothing backuped
if [ -z "$(ls -A ${_BACKUP_PATH})" ]; then
  rm -rf ${_BACKUP_PATH}
fi

) >&3 2>&4 && exit_code="0" || exit_code="$?"
stop_spinner "${exit_code}" \
  "${THIS_HL} are updated [local]" \
  "${THIS_HL} udpate is failed [local]. use VERBOSE=true for error message"

if [ -d ${_BACKUP_PATH} ]; then
  log_info "Your dotfiles have been backed up to ${_BACKUP_PATH} "
fi
