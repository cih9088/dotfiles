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

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="latest"

  if [ "${COMMAND}" == "remove" ]; then
    rm -f "${PREFIX}/share/man/man1/bash-snippets.1" || true
    rm -f "${PREFIX}/bin/transfer" || true
  elif [[ "install update"  == *"${COMMAND}"* ]]; then
    ++ git clone https://github.com/alexanderepstein/Bash-Snippets
    ++ pushd Bash-Snippets
    ++ ./install.sh --prefix="${PREFIX}" transfer
    ++ popd
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list bash-snippets >/dev/null 2>&1 && ++ brew uninstall bash-snippets
      elif [ "${COMMAND}" == "install" ]; then
        brew list bash-snippets >/dev/null 2>&1 || ++ brew install bash-snippets
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade bash-snippets
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -f "/usr/local/share/man/man1/bash-snippets.1"
        ++ sudo rm -f "/usr/local/bin/transfer"
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        ++ git clone https://github.com/alexanderepstein/Bash-Snippets
        ++ pushd Bash-Snippets
        ++ sudo ./install.sh transfer
        ++ popd
      fi
      ;;
      # case "${FAMILY}" in
      #   DEBIAN)
      #     if [ "${COMMAND}" == "remove" ]; then
      #       ++ sudo apt-get -y remove bash-snippets
      #     elif [ "${COMMAND}" == "install" ]; then
      #       ++ sudo apt-get -y install software-properties-common
      #       ++ sudo add-apt-repository -y ppa:navanchauhan/bash-snippets
      #       ++ sudo apt-get update
      #       ++ sudo apt-get -y install bash-snippets
      #     elif [ "${COMMAND}" == "update" ]; then
      #       ++ sudo apt-get -y --only-upgrade install bash-snippets
      #     fi
      #     ;;
      #   RHEL)
      #     if [[ "remove update"  == *"${COMMAND}"* ]]; then
      #       ++ sudo rm -f "/usr/local/share/man/man1/bash-snippets.1"
      #       ++ sudo rm -f "/usr/local/bin/transfer"
      #     fi
      #     if [[ "install update"  == *"${COMMAND}"* ]]; then
      #       ++ git clone https://github.com/alexanderepstein/Bash-Snippets
      #       ++ pushd Bash-Snippets
      #       ++ sudo ./install.sh transfer
      #       ++ popd
      #     fi
      #     ;;
      # esac
      # ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  "" "" ""
