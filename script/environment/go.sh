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

golang_install() {
  local VERSION="${2:-}"

  # prefer goenv
  if command -v goenv > /dev/null; then
    if [ ${VERSION} == "latest" ]; then
      goenv latest install -s
    else
      goenv install ${VERSION}
    fi
  elif command -v asdf > /dev/null; then
    asdf install golang ${VERSION}
  fi
}

golang_version_func() {
  $1 version | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS latest" == *"${1}"* ]]
}

if command -v goenv > /dev/null; then
  eval "$(goenv init -)"
  log_info "Note that ${THIS_HL} would be installed using goenv"
  AVAILABLE_VERSIONS="$(goenv install --list | grep -v 'dev')"
  main_script 'go' golang_install golang_install golang_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
  goenv global $(goenv versions --bare | grep '^[0-9.]\+$' | sort -rV | head)
  goenv global | grep '[0-9.]' -q || goenv global \
    $(goenv versions | sed 's/[[:space:]]//g' | sort -V -r | head -n 1)
elif command -v asdf > /dev/null; then
  asdf plugin list | grep -q golang || asdf plugin add golang >&3 2>&4

  log_info "Note that ${THIS_HL} would be installed using asdf"
  AVAILABLE_VERSIONS="$(asdf list all golang | grep -v 'rc\|beta')"
  main_script 'go' golang_install golang_install golang_version_func \
    "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

  # exit immediately with no reaason
  # asdf current golang >/dev/null 2>&1 || asdf global golang \
  cat $HOME/.tool-versions 2>/dev/null | grep -q golang || asdf global golang \
    $(asdf list golang | sed 's/[[:space:]]//g' | sort -V -r | head -n 1)
else
  log_error "goenv and asdf not found. Install it by 'make installGoenv' or 'make installAsdf' before this."
  exit 1
fi
