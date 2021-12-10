#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="fish-shell/fish-shell"

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
  local VERSION="${2}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -d ${PREFIX}/src/fish-* ]; then
    # uninstall first if force is yes
    if [ ${FORCE} == 'true' ]; then
      pushd ${PREFIX}/src/fish-*
      make uninstall || true
      make clean || true
      rm -rf ${PREFIX}/bin/fish || true
      rm -rf ${PREFIX}/bin/fish_key_reader || true
      rm -rf ${PREFIX}/bin/fish_indent || true
      make clean || true
      popd
      rm -rf ${PREFIX}/src/fish-*
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi
 
  if [ ${DO_INSTALL} == 'true' ]; then
    # download latest version and specify version
    wget https://github.com/${GH}/releases/download/${VERSION}/fish-${VERSION}.tar.xz || exit $?
    tar -xvJf fish-${VERSION}.tar.xz || exit $?

    mv fish-${VERSION} ${PREFIX}/src/
    pushd ${PREFIX}/src/fish-${VERSION}

    mkdir build; pushd build
    cmake .. -DCMAKE_INSTALL_PREFIX=${HOME}/.local || exit $?
    make || exit $?
    make install || exit $?

    popd; popd
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list fish || brew install fish || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade fish || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-add-repository -y ppa:fish-shell/release-${FISH_LATEST_VERSION%%.*} || exit $?
      sudo apt-get -y update || exit $?
      sudo apt-get -y install fish || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      log_error "Not supported"
      exit 1
      # pushd /etc/yum.repos.d/
      # wget https://download.opensuse.org/repositories/shells:fish:release:3/CentOS_8/shells:fish:release:3.repo
      # sudo dnf install -y fish
      # popd
    fi
    # # Adding installed fish to /etc/shells
    # if grep -Fxq "/usr/bin/fish" /etc/shells; then
    #   :
    # else
    #   echo "/usr/bin/fish" | sudo tee -a /etc/shells || exit $?
    # fi
  fi
}

version_func() {
 $1 --version | awk '{print $3}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
