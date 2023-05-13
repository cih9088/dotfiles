#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"
################################################################


BACKUP_PATH="${HOME}/dotfiles.$(date '+%y%m%d%H%M%S').bak"

setup_for_local() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    local configs=(
      "$HOME/.flake8" "$HOME/.pylintrc" "$HOME/.gitignore" "$HOME/.grip"
      "$HOME/.config/nvim" "$HOME/.config/alacritty" "$HOME/.config/iterm2"
      "$HOME/.config/yabai" "$HOME/.config/skhd" "$HOME/.config/sketchybar"
      "$HOME/.config/git" "$HOME/.config/flake8" "$HOME/.config/pylintrc"
      "$HOME/.config/fish" "$HOME/.config/tealdeer" "$HOME/.config/vivid"
      "$HOME/.vim" "$HOME/.tmux" "$HOME/.tmux.conf" "$HOME/.zshrc"
      "$HOME/.zpreztorc" "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zlogout" "$HOME/.zlogin"
      "$HOME/.gnupg/gpg-agent.conf"
    )

    for config in ${configs[@]}; do
      backup "$config"    "$BACKUP_PATH"
      rm -rf "$config"
    done
  elif [ "${COMMAND}" == "install" ] || [ "${COMMAND}" == "update" ]; then
    mkdir -p "${BACKUP_PATH}/config"

    CONFIG_DIR=${PROJ_HOME}/config
    VIM_DIR=${CONFIG_DIR}/vim
    ZSH_DIR=${CONFIG_DIR}/zsh
    TMUX_DIR=${CONFIG_DIR}/tmux
    GNUPG_DIR=${CONFIG_DIR}/gnupg

    # legacy configurations to remove broken configs
    backup "$HOME/.flake8"           "$BACKUP_PATH"
    backup "$HOME/.pylintrc"         "$BACKUP_PATH"
    backup "$HOME/.gitignore"        "$BACKUP_PATH"
    backup "$HOME/.grip"             "$BACKUP_PATH"
    backup "$HOME/.grip"             "$BACKUP_PATH"
    backup "$HOME/.config/bitbar"    "$BACKUP_PATH"
    backup "$HOME/.config/spacebar"  "$BACKUP_PATH"
    backup "$HOME/.config/swiftbar"  "$BACKUP_PATH"
    backup "$HOME/.config/simplebar" "$BACKUP_PATH"
    backup "$HOME/.simplebarrc"      "$BACKUP_PATH"

    # backup old files and replace it with mine
    backup-and-link "${CONFIG_DIR}/nvim"                   "$HOME/.config/nvim"          "$BACKUP_PATH/config"
    backup-and-link "${VIM_DIR}"                           "$HOME/.vim"                  "$BACKUP_PATH"
    # backup-and-link "${VIM_DIR}/vimrc"                     "$HOME/.vimrc"                "$BACKUP_PATH"

    backup-and-link "${CONFIG_DIR}/alacritty"              "$HOME/.config/alacritty"     "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/iterm2"                 "$HOME/.config/iterm2"        "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/yabai"                  "$HOME/.config/yabai"         "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/skhd"                   "$HOME/.config/skhd"          "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/sketchybar"             "$HOME/.config/sketchybar"    "$BACKUP_PATH/config"
    # backup-and-link "${CONFIG_DIR}/bitbar"                 "$HOME/.config/bitbar"        "$BACKUP_PATH/config"
    # backup-and-link "${CONFIG_DIR}/spacebar"               "$HOME/.config/spacebar"      "$BACKUP_PATH/config"
    # backup-and-link "${CONFIG_DIR}/swiftbar"               "$HOME/.config/swiftbar"      "$BACKUP_PATH/config"
    # backup-and-link "${CONFIG_DIR}/simplebar"              "$HOME/.config/simplebar"     "$BACKUP_PATH/config"
    # backup-and-link "${CONFIG_DIR}/simplebar/.simplebarrc" "$HOME/.simplebarrc"          "$BACKUP_PATH"
    backup-and-link "${CONFIG_DIR}/git"                    "$HOME/.config/git"           "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/flake8"                 "$HOME/.config/flake8"        "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/pylintrc"               "$HOME/.config/pylintrc"      "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/fish"                   "$HOME/.config/fish"          "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/tealdeer"               "$HOME/.config/tealdeer"      "$BACKUP_PATH/config"
    backup-and-link "${CONFIG_DIR}/vivid"                  "$HOME/.config/vivid"         "$BACKUP_PATH/config"

    backup-and-link "${TMUX_DIR}"                          "$HOME/.tmux"                 "$BACKUP_PATH"
    backup-and-link "${TMUX_DIR}/tmux.conf"                "$HOME/.tmux.conf"            "$BACKUP_PATH"

    backup-and-link "${ZSH_DIR}/zshrc"                     "$HOME/.zshrc"                "$BACKUP_PATH"
    backup-and-link "${ZSH_DIR}/zpreztorc"                 "$HOME/.zpreztorc"            "$BACKUP_PATH"
    backup-and-link "${ZSH_DIR}/zshenv"                    "$HOME/.zshenv"               "$BACKUP_PATH"
    backup-and-link "${ZSH_DIR}/zprofile"                  "$HOME/.zprofile"             "$BACKUP_PATH"
    backup-and-link "${ZSH_DIR}/zlogout"                   "$HOME/.zlogout"              "$BACKUP_PATH"

    backup-and-link "${GNUPG_DIR}/gpg-agent.conf"          "$HOME/.gnupg/gpg-agent.conf" "$BACKUP_PATH"

    # clean up dotfiles old if there is nothing backuped
    if [ -z "$(ls -A "${BACKUP_PATH}")" ]; then
      rm -rf "${BACKUP_PATH}"
    fi
  fi
}

main_script "${THIS}" \
  setup_for_local ""

if [ -d "${BACKUP_PATH}" ]; then
  log_info "Your configs have been backed up to ${BACKUP_PATH} "
fi
