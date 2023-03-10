#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="akavel/up"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
}

verify_version() {
  local TARGET_VERSION="${1}"
  local AVAILABLE_VERSIONS="${2}"
  AVAILABLE_VERSIONS=$(echo "${AVAILABLE_VERSIONS}" | tr "\n\r" " ")
  [[ " ${AVAILABLE_VERSIONS} " == *" ${TARGET_VERSION} "* ]]
}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/up" ]; then
      rm -rf "${PREFIX}/bin/up" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/up" ]; then

      case ${PLATFORM} in
        OSX )
          ++ curl -LO "https://github.com/akavel/up/releases/download/${VERSION}/up-darwin"
          ++ chmod +x up
          ++ cp -f up-darwin "${PREFIX}/bin/up"
          ;;
        LINUX )
          ++ curl -LO "https://github.com/akavel/up/releases/download/${VERSION}/up"
          ++ chmod +x up
          ++ cp -f up "${PREFIX}/bin/up"
          ;;
      esac
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"
  local VERSION="$(list_versions | head -n 1)"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list up >/dev/null 2>&1 && ++ brew uninstall up
      elif [ "${COMMAND}" == "install" ]; then
        brew list up >/dev/null 2>&1 || ++ brew install up
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade up
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -f /usr/local/bin/up
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        ++ curl -LO "https://github.com/akavel/up/releases/download/${VERSION}/up"
        ++ sudo mkdir -p /usr/local/bin
        ++ sudo cp up /usr/local/bin
        ++ sudo chmod +x /usr/local/bin/up
      fi
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
