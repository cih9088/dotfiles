#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="koalaman/shellcheck"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=shellcheck

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_shellcheck_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z "$VERSION" ] && VERSION=$DEFAULT_VERSION

  if [ -f ${PREFIX}/bin/shellcheck ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf ${PREFIX}/bin/shellcheck || true
      DO_INSTALL='true'
    fi
  else
    DO_INSTALL='true'
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    if [[ ${PLATFORM} == "OSX" ]]; then
      # does not have aarch64 for apple
      wget https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.darwin.x86_64.tar.xz || exit $?
      tar -xvJf shellcheck-${VERSION}.darwin.x86_64.tar.xz || exit $?

      pushd shellcheck-${VERSION}
      yes | \cp -rf shellcheck ${PREFIX}/bin
      popd

    elif [[ ${PLATFORM} == "LINUX" ]]; then
      wget https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.linux.${ARCH}.tar.xz || exit $?
      tar -xvJf shellcheck-${VERSION}.linux.${ARCH}.tar.xz || exit $?

      pushd shellcheck-${VERSION}
      yes | \cp -rf shellcheck ${PREFIX}/bin
      popd
    fi
  fi
}

setup_func_shellcheck_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list shellcheck || brew install shellcheck || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade shellcheck || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install shellcheck || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      log_info "No package in repository. Install it locally."
      setup_func_shellcheck_local ${FORCE}
      # sudo dnf -y install epel-release || exit $?
      # sudo dnf -y install ShellCheck || exit $?
    fi
  fi
}

version_func_shellcheck() {
  $1 --version | head -2 | tail -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_shellcheck_local setup_func_shellcheck_system version_func_shellcheck \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
