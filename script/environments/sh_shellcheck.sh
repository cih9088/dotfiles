#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=sh-env
GH="koalaman/shellcheck"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=shellcheck

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_shellcheck_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=$DEFAULT_VERSION

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/shellcheck" ]; then
      rm -rf "${PREFIX}/bin/shellcheck" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/shellcheck" ]; then

      if [[ ${PLATFORM} == "OSX" ]]; then
        # does not have aarch64 for apple
        ++ curl -LO "https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.darwin.x86_64.tar.xz"
        ++ tar -xvJf "shellcheck-${VERSION}.darwin.x86_64.tar.xz"

        ++ pushd shellcheck-${VERSION}
        ++ cp shellcheck ${PREFIX}/bin
        ++ popd

      elif [[ ${PLATFORM} == "LINUX" ]]; then
        ++ curl -LO "https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.linux.${ARCH}.tar.xz"
        ++ tar -xvJf "shellcheck-${VERSION}.linux.${ARCH}.tar.xz"

        ++ pushd "shellcheck-${VERSION}"
        ++ cp shellcheck "${PREFIX}/bin"
        ++ popd
      fi
    fi
  fi
}

setup_func_shellcheck_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list shellcheck >/dev/null 2>&1 && ++ brew uninstall shellcheck
      elif [ "${COMMAND}" == "install" ]; then
        brew list shellcheck >/dev/null 2>&1 || ++ brew install shellcheck
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade shellcheck
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -f /usr/local/bin/shellcheck
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        ++ curl -LO "https://github.com/koalaman/shellcheck/releases/download/${DEFAULT_VERSION}/shellcheck-${DEFAULT_VERSION}.linux.${ARCH}.tar.xz"
        ++ tar -xvJf "shellcheck-${DEFAULT_VERSION}.linux.${ARCH}.tar.xz"

        ++ pushd "shellcheck-${DEFAULT_VERSION}"
        ++ sudo mkdir -p /usr/local/bin
        ++ sudo cp shellcheck /usr/local/bin
        ++ popd
      fi
      ;;
  esac
}

version_func_shellcheck() {
  $1 --version | head -2 | tail -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_shellcheck_local setup_func_shellcheck_system version_func_shellcheck \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
