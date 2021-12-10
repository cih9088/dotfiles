#!/usr/bin/env bash
# based on https://gist.github.com/ryin/3106801#gistcomment-2191503
# tmux will be installed in ${PREFIX}/bin if you specify to install without root access
# It's assumed that wget and a C/C++ compiler are installed.


################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="tmux/tmux"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -d ${PREFIX}/src/tmux-* ]; then
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/tmux-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/tmux-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    wget https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz
    tar -xvzf tmux-${VERSION}.tar.gz

    mv tmux-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/tmux-${VERSION}

    ./configure --prefix=${PREFIX}
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list reattach-to-user-namespace || brew install reattach-to-user-namespace || exit $?
    brew list tmux || brew install tmux || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade reattach-to-user-namespace || exit $?
      brew upgrade tmux || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install tmux || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      sudo dnf -y install tmux || exit $?
    fi
  fi

}

version_func() {
  $1 -V | awk '{print $2}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
