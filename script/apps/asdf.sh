#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

version_func() {
  $1 version
}

setup_for_local() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
      chown -R $(whoami) ${HOME}/.asdf
      rm -rf ${HOME}/.asdf || true
    fi
  elif [ "${COMMAND}" == "install" ]; then
    if [ ! -f "${HOME}/.asdf/asdf.sh" ]; then
      ++ git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf
      ++ pushd ${HOME}/.asdf
      ++ git checkout "$(git describe --abbrev=0 --tags)"
      ++ popd

      # direnv
      . $HOME/.asdf/asdf.sh
      ++ asdf plugin add direnv
      ++ asdf direnv setup --shell zsh --version latest
      # ++ asdf direnv setup --shell bash --version latest
      # ++ asdf direnv setup --shell fish --version latest
      ++ asdf global direnv latest
    fi
  elif [ "${COMMAND}" == "update" ]; then
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
      . $HOME/.asdf/asdf.sh
      ++ asdf update
      ++ asdf plugin update --all
    else
      log_error "${THIS_HL} is not installed. Please install it before update it."
      exit 1
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list asdf >/dev/null 2>&1 && ++ brew uninstall asdf
      elif [ "${COMMAND}" == "install" ]; then
        brew list asdf >/dev/null 2>&1 || ++ brew install asdf
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade asdf
      fi
      ;;
    LINUX)
      log_info "Not able to ${COMMAND} ${THIS} systemwide."
      setup_for_local "${COMMAND}"
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  "" "" version_func
