#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

log_title "Prepare to ${BOLD}${UNDERLINE}install ${THIS}${NC}"

DEFAULT_VERSION=latest
###############################################################

setup_func_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -d ${PREFIX}/src/zsh-* ]; then
    # uninstall first if force is yes
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/zsh-*
      make uninstall || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/zsh-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    # download latest version and specify version
    if [[ ${VERSION} == "latest" ]]; then
      wget https://sourceforge.net/projects/zsh/files/latest/download \
        -O zsh-${VERSION}.tar.xz || exit $?
      tar -xvJf zsh-${VERSION}.tar.xz || exit $?
      for file in ./*; do
        if [[ -d "${file}" ]] && [[ "${file}" == *"zsh-"* ]]; then
          VERSION=$(echo ${file##*zsh-})
        fi
      done
    else
      wget https://sourceforge.net/projects/zsh/files/zsh/${VERSION}/zsh-${VERSION}.tar.xz/download \
        -O zsh-${VERSION}.tar.xz || exit $?
      tar -xvJf zsh-${VERSION}.tar.xz || exit $?
    fi

    mv zsh-${VERSION} ${PREFIX}/src
    pushd ${PREFIX}/src/zsh-${VERSION}

    ./configure --prefix=${PREFIX} || exit $?
    make || exit $?
    make install || exit $?

    popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list zsh || brew install zsh || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade zsh || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install zsh || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      sudo dnf -y install zsh || exit $?
    fi

    # # Adding installed zsh to /etc/shells
    # if grep -Fxq "/usr/bin/zsh" /etc/shells; then
    #   :
    # else
    #   echo "/usr/bin/zsh" | sudo tee -a /etc/shells || exit $?
    # fi

  fi
}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  if [[ ${1} != 'latest' ]]; then
    curl -s --head \
      https://sourceforge.net/projects/zsh/files/zsh/${1}/zsh-${1}.tar.xz/download |
      head -n 1 | grep "HTTP/1.[01] [23].." || EXIT_CODE=${?} > /dev/null
    if [[ ${EXIT_CODE:-0} != 0 ]]; then
      log_error "${1} is not a valid version."
      log_error "please visit https://sourceforge.net/projects/zsh/files/zsh/ for listing valid versions."
      exit ${EXIT_CODE}
    fi
  fi
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "" verify_version
