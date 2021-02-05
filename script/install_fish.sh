#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install fish${Color_Off}"

FISH_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release fish-shell/fish-shell)"
FISH_VERSION=${1:-${FISH_LATEST_VERSION}}
$(${PROJ_HOME}/script/check_release fish-shell/fish-shell ${FISH_VERSION}) || exit $?

################################################################

setup_func_local() {
 force=$1
 cd $TMP_DIR

 # if fish has been already instlled before
 install=no
 if [ -f ${HOME}/.local/bin/fish ]; then
  # uninstall first if force is yes
  if [ ${force} == 'true' ]; then
   if [ -d $HOME/.local/src/fish-* ]; then
    cd $HOME/.local/src/fish-*
    # make uninstall || true
    rm -rf $HOME/.local/bin/fish || true
    rm -rf $HOME/.local/bin/fish_key_reader || true
    rm -rf $HOME/.local/bin/fish_indent || true
    make clean || true
    cd -
    rm -rf $HOME/.local/src/fish-*
   fi
   install=true
  fi
 else
  install=true
 fi

 if [ ${install} == 'true' ]; then
  # download latest version and specify version
  wget https://github.com/fish-shell/fish-shell/releases/download/${FISH_VERSION}/fish-${FISH_VERSION}.tar.gz
  tar -xvzf fish-${FISH_VERSION}.tar.gz
  cd fish-${FISH_VERSION}
  mkdir build; cd build
  cmake ..  -DCMAKE_INSTALL_PREFIX=${HOME}/.local
  make || exit $?
  make install || exit $?
  cd ../..
  mv fish-${FISH_VERSION} $HOME/.local/src
 fi
}

setup_func_system() {
 force=$1
 cd $TMP_DIR

 if [[ $platform == "OSX" ]]; then
  brew list fish || brew install fish
  if [ ${force} == 'true' ]; then
   brew upgrade fish
  fi
 elif [[ $platform == "LINUX" ]]; then
  sudo apt-add-repository ppa:fish-shell/release-${FISH_LATEST_VERSION%%.*}
  sudo apt-get update
  sudo apt-get install fish
  # Adding installed fish to /etc/shells
  if grep -Fxq "/usr/bin/fish" /etc/shells; then
   :
  else
   echo "/usr/bin/fish" | sudo tee -a /etc/shells
  fi
 fi
}

version_func() {
 $1 --version | awk '{print $3}'
}

main_script 'fish' setup_func_local setup_func_system version_func
