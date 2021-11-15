#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install nvim${Color_Off}"

NVIM_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release neovim/neovim)"
NVIM_VERSION=${1:-${NVIM_LATEST_VERSION##v}}
if [[ ${NVIM_VERSION} != 'nightly' ]] && [[ ${NVIM_VERSION} != 'stable' ]] && [[ ${NVIM_VERSION} != "v"* ]]; then
  NVIM_VERSION="v${NVIM_VERSION}"
fi
$(${PROJ_HOME}/script/check_release neovim/neovim ${NVIM_VERSION}) || exit $?

# # use sytem python
# export VIRTUALENVWRAPPER_PYTHON=$(which python)
# export VIRTUALENVWRAPPER_VIRTUALENV=$(which virtualenv)
# export VIRTUALENVWRAPPER_SCRIPT=$(which virtualenvwrapper.sh)
# export VIRTUALENVWRAPPER_LAZY_SCRIPT=$(which virtualenvwrapper_lazy.sh)
# export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
# export PYENV_ROOT=${HOME}/.pyenv
# export PATH="${HOME}/.pyenv/bin:$PATH"

# if asdf is installed
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
export PATH="${HOME}/.pyenv/bin:$PATH"
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true

export WORKON_HOME=${HOME}/.virtualenvs
mkdir -p ${WORKON_HOME} || true

neovim3_virenv='neovim3'
neovim2_virenv='neovim2'
################################################################

setup_func_python_support() {
  pip install virtualenv

  rm -rf ${WORKON_HOME}/${neovim2_virenv}
  virtualenv --python=$(which python2) ${WORKON_HOME}/${neovim2_virenv}
  source ${WORKON_HOME}/${neovim2_virenv}/bin/activate
  pip install neovim

  rm -rf ${WORKON_HOME}/${neovim3_virenv}
  virtualenv --python=$(which python3) ${WORKON_HOME}/${neovim3_virenv}
  source ${WORKON_HOME}/${neovim3_virenv}/bin/activate
  pip install neovim
}

setup_func_local() {
  force=$1
  cd $TMP_DIR

  install=no
  if [ -x "$(command -v ${HOME}/.local/bin/nvim)" ]; then
    if [ ${force} == 'true' ]; then
      rm -rf ${HOME}/.local/bin/nvim || true
      rm -rf ${HOME}/.local/man/man1/nvim.1 || true
      rm -rf ${HOME}/.local/share/nvim/runtim || true
      install=true
    fi
  else
    install=true
  fi

  if [ ${install} == 'true' ]; then
    if [[ $platform == "OSX" ]]; then
      wget https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-macos.tar.gz
      tar -xvzf nvim-macos.tar.gz
      yes | \cp -rf nvim-osx64/* $HOME/.local/
    elif [[ $platform == "LINUX" ]]; then
      wget https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage
      # https://github.com/neovim/neovim/issues/7620
      # https://github.com/neovim/neovim/issues/7537
      chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract
      yes | \cp -rf squashfs-root/usr/bin $HOME/.local
      yes | \cp -rf squashfs-root/usr/man $HOME/.local
      yes | \cp -rf squashfs-root/usr/share/nvim $HOME/.local/share
      # yes | \cp -rf squashfs-root/usr/* $HOME/.local
      # chmod u+x nvim.appimage && mv nvim.appimage nvim
      # cp nvim $HOME/.local/bin
    fi
    setup_func_python_support ${force}
  fi
}

setup_func_system() {
  force=$1
  cd $TMP_DIR

  if [[ $platform == "OSX" ]]; then
    brew list neovim || brew install neovim
    if [ ${force} == 'true' ]; then
      brew upgrade neovim
    fi
  elif [[ $platform == "LINUX" ]]; then
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get -y update
    sudo apt-get -y install neovim
  fi
  setup_func_python_support ${force}
}

version_func() {
  $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'nvim' setup_func_local setup_func_system version_func
