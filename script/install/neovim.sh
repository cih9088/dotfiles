#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="neovim/neovim"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="nvim"

log_title "Prepare to install ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"

# # use sytem python
# export VIRTUALENVWRAPPER_PYTHON=$(which python)
# export VIRTUALENVWRAPPER_VIRTUALENV=$(which virtualenv)
# export VIRTUALENVWRAPPER_SCRIPT=$(which virtualenvwrapper.sh)
# export VIRTUALENVWRAPPER_LAZY_SCRIPT=$(which virtualenvwrapper_lazy.sh)
# export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
# export PYENV_ROOT=${HOME}/.pyenv
# export PATH="${HOME}/.pyenv/bin:$PATH"

# python virtualenv path
export WORKON_HOME=${HOME}/.virtualenvs
mkdir -p ${WORKON_HOME} || true

neovim3_virenv='neovim3'
neovim2_virenv='neovim2'
################################################################

setup_func_python_support() {
  pip3 install --user virtualenv

  rm -rf ${WORKON_HOME}/${neovim2_virenv} || true
  virtualenv --python=$(which python2) ${WORKON_HOME}/${neovim2_virenv}
  source ${WORKON_HOME}/${neovim2_virenv}/bin/activate
  pip install --upgrade pynvim

  rm -rf ${WORKON_HOME}/${neovim3_virenv} || true
  virtualenv --python=$(which python3) ${WORKON_HOME}/${neovim3_virenv}
  source ${WORKON_HOME}/${neovim3_virenv}/bin/activate
  pip install --upgrade pynvim
}

setup_func_local() {
  local FORCE="${1}"
  local VERSION="${2:-}"
  local DO_INSTALL="no"

  [ -z $VERSION ] && VERSION=$DEFAULT_VERSION

  if [ -x "$(command -v ${HOME}/.local/bin/nvim)" ]; then
    if [ ${FORCE} == 'true' ]; then
      rm -rf ${HOME}/.local/bin/nvim || true
      rm -rf ${HOME}/.local/man/man1/nvim.1 || true
      rm -rf ${HOME}/.local/share/nvim/runtim || true
      DO_INSTALL=true
    fi
  else
    DO_INSTALL=true
  fi

  if [ ${DO_INSTALL} == 'true' ]; then
    if [[ ${PLATFORM} == "OSX" ]]; then
      if [ ${ARCH} == "X86_64" ]; then
        wget https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-macos.tar.gz || exit $?
        tar -xvzf nvim-macos.tar.gz || exit $?
        yes | \cp -rf nvim-osx64/* $HOME/.local/
      else
        log_error "${ARCH} not supported. Install it manually."; exit 1
      fi
    elif [[ ${PLATFORM} == "LINUX" ]]; then
      if [ ${ARCH} == "x86_64" ]; then
        wget https://github.com/neovim/neovim/releases/download/${VERSION}/nvim.appimage
        # https://github.com/neovim/neovim/issues/7620
        # https://github.com/neovim/neovim/issues/7537
        chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract || exit $?
        yes | \cp -rf squashfs-root/usr/bin $HOME/.local
        yes | \cp -rf squashfs-root/usr/man $HOME/.local
        yes | \cp -rf squashfs-root/usr/share/nvim $HOME/.local/share
        # yes | \cp -rf squashfs-root/usr/* $HOME/.local
        # chmod u+x nvim.appimage && mv nvim.appimage nvim
        # cp nvim $HOME/.local/bin

      elif [ ${ARCH} == "aarch64" ]; then
        # no arm built binary
        # https://github.com/neovim/neovim/pull/15542
        git clone https://github.com/neovim/neovim || exit $?

        mv neovim $HOME/.local/src
        pushd $HOME/.local/src/neovim
        git checkout ${VERSION}

        make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local" CMAKE_BUILD_TYPE=Release || exit $?
        make install || exit $?

        popd
      else
        log_error "${ARCH} not supported. Install it manually."; exit 1
      fi
    fi
    setup_func_python_support ${FORCE}
  fi
}

setup_func_system() {
  local FORCE=$1

  if [[ ${PLATFORM} == "OSX" ]]; then
    brew list neovim || brew install neovim || exit $?
    if [ ${FORCE} == 'true' ]; then
      brew upgrade neovim || exit $?
    fi
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    if [[ $FAMILY == "DEBIAN" ]]; then
      sudo apt-get -y install neovim || exit $?
    elif [[ $FAMILY == "RHEL" ]]; then
      sudo dnf -y install epel-release || exit $?
      sudo dnf -y install neovim || exit $?
    fi
  fi
  setup_func_python_support ${FORCE}
}

version_func() {
  $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
