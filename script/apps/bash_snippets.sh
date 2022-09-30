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
################################################################

setup_func_bash_snippets_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  if [ "${COMMAND}" == "remove" ]; then
    rm -f "${PREFIX}/share/man/man1/bash-snippets.1" || true
    rm -f "${PREFIX}/bin/cheat" || true
    rm -f "${PREFIX}/bin/transfer" || true
  elif [[ "install update"  == *"${COMMAND}"* ]]; then
    ++ git clone https://github.com/alexanderepstein/Bash-Snippets
    ++ pushd Bash-Snippets
    ++ ./install.sh --prefix=${PREFIX} transfer cheat
    ++ popd
  fi
}

setup_func_bash_snippets_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list bash-snippets >/dev/null 2>&1 && ++ brew uninstall bash-snippets
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list bash-snippets >/dev/null 2>&1 || ++ brew install bash-snippets
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade bash-snippets
      fi
      ;;
    LINUX)
      log_error "No package in repository. Please install it in local mode"
      exit 1
      ;;
  esac
}

main_script ${THIS} setup_func_bash_snippets_local setup_func_bash_snippets_system "" \
  "${DEFAULT_VERSION}"
