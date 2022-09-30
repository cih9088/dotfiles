#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################
THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="latest"
###############################################################

setup_func() {
  local FORCE="${1}"
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    if [ -d "$HOME/.zprezto" ]; then
      rm -rf "$HOME/.zprezto" || true
    fi
  elif [ "${COMMAND}" == "install" ]; then
    if [ ! -d "$HOME/.zprezto" ]; then
      # Clone prezto the repository
      ++ git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
      # Clone prezto-contrib repository
      ++ git clone --recurse-submodules https://github.com/belak/prezto-contrib "$HOME/.zprezto/contrib"

      # pure prompt update
      cd ${HOME}/.zprezto/modules/prompt/external/pure
      ++ git checkout main
      ++ git pull
      ## Clone garrett prompt repository
      #git clone https://github.com/cih9088/zsh-prompt-garrett.git ./prompt
      #
      #cd prompt
      #cp prompt_garrett_setup ~/.zprezto/modules/prompt/functions/
      #cd ..
      #rm -rf prompt
      #

      # Create a new zsh configureation by copying the zsh config files
      for rcfile in $HOME/.zprezto/runcoms/z*; do
        ln -s "$rcfile" "$HOME/.$(basename ${rcfile})" || true
      done
    fi
  elif [ "${COMMAND}" == "update" ]; then
    if [ -d "$HOME/.zprezto" ]; then
      # update prezto
      ++ cd ~/.zprezto
      ++ git pull
      ++ git submodule update --init --recursive

      # update pure prompt
      ++ cd ${HOME}/.zprezto/modules/prompt/external/pure
      ++ git checkout main
      ++ git pull
    else
      log_error "${THIS_HL} is not installed. Please install it before update it."
      exit 1
    fi
  fi
}

main_script ${THIS} setup_func setup_func "" \
  "${DEFAULT_VERSION}"
