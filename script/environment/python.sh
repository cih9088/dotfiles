#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare environment for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

python2_install() {
  local VERSION="${2:-}"

  # prefer pyenv
  if command -v pyenv > /dev/null; then
    if [ -z ${VERSION} ]; then
      log_info "List of version"
      pyenv install --list | grep '^2' | grep -v 'dev'
      VERSION=$(question "Choose python2 version to install", ${DEFAULT_VERSION})
    fi
    if [ ${VERSION} == "latest" ]; then
      pyenv latest install -s 2
    else
      pyenv install ${VERSION}
    fi
  elif command -v asdf > /dev/null; then
    if [ -z ${VERSION} ]; then
      log_info "List of version"
      asdf list all python 2 | grep -v 'dev'
      VERSION=$(question "Choose python2 version to install", ${DEFAULT_VERSION})
    fi
    if [ ${VERSION} == "latest" ]; then
      asdf install python latest:2
    else
      asdf install python ${VERSION}
    fi
  fi
}

python3_install() {
  local VERSION="${2:-}"

  # prefer pyenv
  if command -v pyenv > /dev/null; then
    if [ -z ${VERSION} ]; then
      log_info "List of version"
      pyenv install --list | grep '^3' | grep -v 'dev'
      VERSION=$(question "Choose python3 version to install", ${DEFAULT_VERSION})
    fi
    if [ ${VERSION} == "latest" ]; then
      pyenv latest install -s 3
    else
      pyenv install ${VERSION}
    fi
  elif command -v asdf > /dev/null; then
    if [ -z ${VERSION} ]; then
      log_info "List of version"
      asdf list all python 3 | grep -v 'dev'
      VERSION=$(question "Choose python3 version to install", ${DEFAULT_VERSION})
    fi
    if [ ${VERSION} == "latest" ]; then
      asdf install python latest:3
    else
      asdf install python ${VERSION}
    fi
  fi
}

python_version_func() {
  $1 --version 2>&1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS latest" == *"${1}"* ]]
}


if command -v pyenv > /dev/null; then
  # install latest plugin if not installed
  [ ! -d ${PYENV_ROOT}/plugins/xxenv-latest ] && \
    git clone https://github.com/momo-lab/xxenv-latest.git ${PYENV_ROOT}/plugins/xxenv-latest
  eval "$(pyenv init -)"
  log_info "Note that ${THIS_HL}2 would be installed using pyenv"
  main_script 'python2' python2_install python2_install python_version_func
  log_info "Note that ${THIS_HL}3 would be installed using pyenv"
  main_script 'python3' python3_install python3_install python_version_func
  pyenv global | grep '[0-9.]' -q || pyenv global \
    $(pyenv versions | sed 's/[[:space:]]//g' | grep '^3' | sort -V -r | head -n 1) \
    $(pyenv versions | sed 's/[[:space:]]//g' | grep '^2' | sort -V -r | head -n 1)
elif command -v asdf > /dev/null; then
  asdf plugin list | grep -q python || asdf plugin add python >&3 2>&4

  log_info "Note that ${THIS_HL}2 would be installed using asdf"
  AVAILABLE_VERSIONS="$(asdf list all python 2 | grep -v 'dev')"
  main_script 'python2' python2_install python2_install python_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

  log_info "Note that ${THIS_HL}3 would be installed using asdf"
  AVAILABLE_VERSIONS="$(asdf list all python 3 | grep -v 'dev')"
  main_script 'python3' python3_install python3_install python_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

  # exit immediately with no reaason
  # asdf current python >/dev/null 2>&1 || asdf global python \
  cat $HOME/.tool-versions 2>/dev/null | grep -q python || asdf global python \
    $(asdf list python | sed 's/[[:space:]]//g' | grep '^3' | sort -V -r | head -n 1) \
    $(asdf list python | sed 's/[[:space:]]//g' | grep '^2' | sort -V -r | head -n 1)
else
  log_error "pyenv and asdf not found. Install it by 'make installPyenv' or 'make installAsdf' before this."
  exit 1
fi

# upgrade pip
command -v python2 >/dev/null && python2 -m pip install --upgrade pip >&3 2>&4
command -v python3 >/dev/null && python3 -m pip install --upgrade pip >&3 2>&4
