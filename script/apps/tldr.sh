#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="dbrgn/tealdeer"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_tldr_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # uninstall slow tldr client
  has pip2 && pip2 uninstall --yes tldr >/dev/null 2>&1 || true
  has pip3 && pip3 uninstall --yes tldr >/dev/null 2>&1 || true

  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/tldr" ]; then
      rm -rf "${PREFIX}/bin/tldr" || true
    fi
  fi

  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f ${PREFIX}/bin/tldr ]; then

      # name is changed after version v1.5.0
      _name="tldr"
      if [ "$(printf '%s\n%s' ${VERSION} v1.5.0 | sort -V | head -n 1)" == "v1.5.0" ]; then
        _name="tealdeer"
      fi

      if [ "${ARCH}" == "x86_64" ]; then
        ++ curl -LO "https://github.com/dbrgn/tealdeer/releases/download/${VERSION}/${_name}-linux-x86_64-musl"
        ++ mv "${_name}-linux-x86_64-musl" "${PREFIX}/bin/tldr"
      elif [ "${ARCH}" == "aarch64" ]; then
        ++ curl -LO "https://github.com/dbrgn/tealdeer/releases/download/${VERSION}/${_name}-linux-armv7-musleabihf"
        ++ mv "${_name}-linux-armv7-musleabihf" "${PREFIX}/bin/tldr"
      fi
      ++ chmod +x "${PREFIX}/bin/tldr"
      ++ "${PREFIX}/bin/tldr" --update
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi
}

setup_func_tldr_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list tealdeer >/dev/null 2>&1 && ++ brew uninstall tealdeer
      elif [ "${COMMAND}" == "install" ]; then
        brew list tealdeer >/dev/null 2>&1 || ++ brew install tealdeer
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade tealdeer
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -rf /usr/local/bin/tldr
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        ++ sudo mkdir -p /usr/local/bin
        if [ "${ARCH}" == "x86_64" ]; then
          ++ curl -LO "https://github.com/dbrgn/tealdeer/releases/download/${DEFAULT_VERSION}/tealdeer-linux-x86_64-musl"
          ++ sudo mv "tealdeer-linux-x86_64-musl" "/usr/local/bin/tldr"
          ++ sudo chmod +x /usr/local/bin/tldr
        elif [ "${ARCH}" == "aarch64" ]; then
          ++ curl -LO "https://github.com/dbrgn/tealdeer/releases/download/${DEFAULT_VERSION}/tealdeer-linux-armv7-musleabihf"
          ++ sudo mv "tealdeer-linux-armv7-musleabihf" "/usr/local/bin/tldr"
          ++ sudo chmod +x /usr/local/bin/tldr
        fi
        ++ sudo chmod +x /usr/local/bin/tldr
        ++ /usr/local/bin/tldr --update
      fi
      ;;
  esac
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_tldr_local setup_func_tldr_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
