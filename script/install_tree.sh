#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install tree${Color_Off}"

TREE_VERSION=${1:-1.8.0}
################################################################


setup_func_tree_local() {
  force=$1
  cd $TMP_DIR

  install=no
  if [ -d $HOME/.local/src/tree-* ]; then
    if [ ${force} == 'true' ]; then
      cd $HOME/.local/src/tree-*
      make clean || true
      cd ..
      rm -rf $HOME/.local/src/tree-*
      install=true
    fi
  else
    install=true
  fi

  if [ ${install} == 'true' ]; then
    cd $TMP_DIR
    wget http://mama.indstate.edu/users/ice/tree/src/tree-${TREE_VERSION}.tgz
    tar -xvzf tree-${TREE_VERSION}.tgz
    cd tree-${TREE_VERSION}
    sed -i -e "s|prefix = /usr|prefix = $HOME/.local|" Makefile
    make || exit $?
    make install || exit $?
    cd $TMP_DIR
    rm -rf $HOME/.local/src/tree-*
    mv tree-${TREE_VERSION} $HOME/.local/src
  fi
}

setup_func_tree_system() {
  force=$1
  cd $TMP_DIR

  if [[ $platform == "OSX" ]]; then
    brew list tree || brew install tree
    if [ ${force} == 'true' ]; then
      brew upgrade tree
    fi
  elif [[ $platform == "LINUX" ]]; then
    sudo apt-get -y remove tree
    sudo apt-get -y install tree
  fi
}

version_func_tree() {
  $1 --version | awk '{print $2}'
}

main_script 'tree' setup_func_tree_local setup_func_tree_system version_func_tree
