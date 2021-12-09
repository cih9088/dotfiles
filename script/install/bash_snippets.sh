#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

setup_func_bash_snippets_local() {
  local FORCE=$1

  git clone https://github.com/alexanderepstein/Bash-Snippets || exit $?

  pushd Bash-Snippets

  ./install.sh --prefix=$HOME/.local transfer cheat

  popd
}

setup_func_bash_snippets_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list bash-snippets || brew install bash-snippets || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade bash-snippets || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    git clone https://github.com/alexanderepstein/Bash-Snippets || exit $?

    pushd Bash-Snippets

    ./install.sh transfer cheat || exit $?

    popd
  fi
}

main_script ${THIS} setup_func_bash_snippets_local setup_func_bash_snippets_system "" \
  "${DEFAULT_VERSION}"
