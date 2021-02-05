#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install zsh${Color_Off}"

ZSH_LATEST_VERSION=latest
ZSH_VERSION=${1:-${ZSH_LATEST_VERSION}}
if [[ ${ZSH_VERSION} != 'latest' ]]; then
  curl -s \
    --head https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz/download \
    | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
  exit_code=${?}
  if [[ ${exit_code} != 0 ]]; then
    printf "\033[2K\033[${ctr}D[0;91m[!][0m" >&2
    printf " ${ZSH_VERSION} is not a valid version\n" >&2
    printf "\033[2K\033[${ctr}D[0;91m[!][0m" >&2
    printf " please visit https://sourceforge.net/projects/zsh/files/zsh/ for valid versions\n" >&2
    exit ${exit_code}
  fi
fi


################################################################

setup_func_local() {
  force=$1
  cd $TMP_DIR

  # download latest version and specify version
  if [[ ${ZSH_VERSION} == "latest" ]]; then
    wget https://sourceforge.net/projects/zsh/files/latest/download -O zsh-${ZSH_VERSION}.tar.xz
    tar -xvJf zsh-${ZSH_VERSION}.tar.xz
    for file in ./*; do
      if [[ -d "${file}" ]] && [[ "${file}" == *"zsh-"* ]]; then
        ZSH_VERSION=$(echo ${file##*zsh-})
      fi
    done
  else
    wget https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz/download -O zsh-${ZSH_VERSION}.tar.xz
    tar -xvJf zsh-${ZSH_VERSION}.tar.xz
  fi

  # if zsh has been already instlled before
  install=no
  if [ -f ${HOME}/.local/bin/zsh ]; then
    # uninstall first if force is yes
    if [ ${force} == 'true' ]; then
      if [ -d $HOME/.local/src/zsh-* ]; then
        cd $HOME/.local/src/zsh-*
        make uninstall || true
        make clean || true
        cd -
        rm -rf $HOME/.local/src/zsh-*
      fi
      install=true
    fi
  else
    install=true
  fi

  if [ ${install} == 'true' ]; then
    cd zsh-${ZSH_VERSION}
    ./configure --prefix=$HOME/.local
    make || exit $?
    make install || exit $?
    cd -
    mv zsh-${ZSH_VERSION} $HOME/.local/src
  fi
}

setup_func_system() {
  force=$1
  cd $TMP_DIR

  if [[ $platform == "OSX" ]]; then
    brew list zsh || brew install zsh
    if [ ${force} == 'true' ]; then
      brew upgrade zsh
    fi
  elif [[ $platform == "LINUX" ]]; then
    sudo apt-get -y install zsh
    # Adding installed zsh to /etc/shells
    if grep -Fxq "/usr/bin/zsh" /etc/shells; then
      :
    else
      echo "/usr/bin/zsh" | sudo tee -a /etc/shells
    fi
  fi
}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

main_script 'zsh' setup_func_local setup_func_system version_func
