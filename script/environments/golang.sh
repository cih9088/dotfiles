#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="go"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  local COMMAND=${1:-install}

  if command -v goenv > /dev/null; then
    if [ "$COMMAND" == "remove" ]; then
      goenv versions --bare | sort -Vr
    else
      goenv install -l | grep -v '[a-zA-Z]' | sort -Vr
    fi
  elif command -v mise > /dev/null; then
    echo "latest"
    mise ls-remote golang | grep -v '[a-zA-Z]' | sort -Vr
  elif command -v asdf > /dev/null; then
    asdf plugin list 2>/dev/null | grep -q golang || asdf plugin add golang >&3 2>&4
    if [ "$COMMAND" == "remove" ]; then
      asdf list golang | sed -e 's/ //g' -e 's/*//g' | sort -Vr
    else
      asdf list all golang | grep -v '[a-zA-Z]' | sort -Vr
    fi
  fi
}

version_func() {
  $1 version | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  local TARGET_VERSION="${1}"
  local AVAILABLE_VERSIONS="${2}"
  AVAILABLE_VERSIONS=$(echo "${AVAILABLE_VERSIONS}" | tr "\n\r" " ")
  [[ " ${AVAILABLE_VERSIONS} " == *" ${TARGET_VERSION} "* ]]
}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  # prefer goenv
  if command -v goenv > /dev/null; then
    eval "$(goenv init -)"
    log_info "Note that ${THIS_HL} would be handled by goenv."
    from_goenv "$COMMAND" "$VERSION"
  elif command -v mise > /dev/null; then
    log_info "Note that ${THIS_HL} would be handled by mise."
    from_mise "$COMMAND" "$VERSION"
  elif command -v asdf > /dev/null; then
    log_info "Note that ${THIS_HL} would be handled by asdf."
    from_asdf "$COMMAND" "$VERSION"
  else
    log_error "Install from source is not implemented."
    exit 1
  fi
}

from_goenv() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions $COMMAND | head -n 1)"

  if [ "${VERSION}" == "latest" ]; then
    VERSION=$(goenv latest -p)
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ goenv uninstall -f "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ goenv install "${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi

  goenv global $(goenv versions --bare | grep '^[0-9.]\+$' | sort -rV | head)
  goenv global | grep '[0-9.]' -q || goenv global \
    $(goenv versions | sed 's/[[:space:]]//g' | sort -V -r | head -n 1)
}

from_asdf() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=latest

  asdf plugin list 2>/dev/null | grep -q golang || asdf plugin add golang >&3 2>&4

  if [ "${VERSION}" == "latest" ]; then
    VERSION=$(asdf latest golang)
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ asdf uninstall golang "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ asdf install golang "${VERSION}"
    ++ asdf set -u golang "${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi
}

from_mise() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=latest

  if [ "${COMMAND}" == "remove" ]; then
    ++ mise unuse -g -y "golang@${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ mise use -g -v "golang@${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi
}

main_script "${THIS}" \
  setup_for_local "" \
  list_versions verify_version version_func
