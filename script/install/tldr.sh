#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="dbrgn/tealdeer"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_tldr_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -f ${PREFIX}/bin/tldr ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf ${PREFIX}/bin/tldr || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  # uninstall slow tldr client
  pip2 uninstall --yes tldr || true
  pip3 uninstall --yes tldr || true

  if [ ${ARCH} == "x86_64" ]; then
    wget https://github.com/dbrgn/tealdeer/releases/download/${VERSION}/tldr-linux-x86_64-musl || exit $?
    mv tldr-linux-x86_64-musl ${PREFIX}/bin/tldr || exit $?
  elif [ ${ARCH} == "aarch64" ]; then
    wget https://github.com/dbrgn/tealdeer/releases/download/${VERSION}/tldr-linux-armv7-musleabihf || exit $?
    mv tldr-linux-armv7-musleabihf ${PREFIX}/bin/tldr || exit $?
  fi
  chmod +x ${PREFIX}/bin/tldr
  ${PREFIX}/bin/tldr --update
}

setup_func_tldr_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    # uninstall slow tldr client
    brew list tldr && brew uninstall tldr
    brew list tealdeer || brew install tealdeer || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade tealdeer || exit $?
    fi
    $(brew --prefix)/bin/tldr --update
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    setup_func_tldr_local ${FORCE}
  fi
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_tldr_local setup_func_tldr_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
