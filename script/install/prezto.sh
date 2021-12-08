#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

log_title "Prepare to ${BOLD}${UNDERLINE}install ${THIS}${NC}"

###############################################################

setup_func() {
  local FORCE="${1}"

  if [ -d "$HOME/.zprezto" ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf "$HOME/.zprezto" || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    # Clone prezto the repository
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto" || exit $?
    # Clone prezto-contrib repository
    git clone --recurse-submodules https://github.com/belak/prezto-contrib "$HOME/.zprezto/contrib" || exit $?

    # pure prompt update
    cd ${HOME}/.zprezto/modules/prompt/external/pure
    git checkout main
    git pull
    ## Clone garrett prompt repository
    #git clone https://github.com/cih9088/zsh-prompt-garrett.git ./prompt
    #
    #cd prompt
    #cp prompt_garrett_setup ~/.zprezto/modules/prompt/functions/
    #cd ..
    #rm -rf prompt
    #
  fi

  # Create a new zsh configureation by copying the zsh config files
  for rcfile in $HOME/.zprezto/runcoms/z*; do
    ln -s "$rcfile" "$HOME/.$(basename ${rcfile})" || true
  done
}

main_script ${THIS} setup_func setup_func ""
