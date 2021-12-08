#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="node"

log_title "Prepare environment for ${THIS_HL}"

DEFAULT_VERSION="latest"
################################################################

# nodejs_install() {
#   local VERSION="${2:-}"
#
#   if command -v asdf > /dev/null; then
#     asdf install nodejs ${VERSION}
#   fi
# }
#
# nodejs_version_func() {
#   $1 --version
# }
#
# verify_version() {
#   [[ "$AVAILABLE_VERSIONS latest" == *"${1}"* ]]
# }
#
# if command -v asdf > /dev/null; then
#   asdf plugin list | grep -q nodejs || asdf plugin add nodejs >&3 2>&4
#
#   log_info "Note that ${THIS_HL} would be installed using asdf"
#   AVAILABLE_VERSIONS="$(asdf list all nodejs)"
#   main_script ${THIS} nodejs_install nodejs_install nodejs_version_func \
#     "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
#
#   # exit immediately with no reaason
#   # asdf current nodejs >/dev/null 2>&1 || asdf global nodejs \
#   cat $HOME/.tool-versions 2>/dev/null | grep -q nodejs || asdf global nodejs \
#     $(asdf list nodejs | sed 's/[[:space:]]//g' | sort -V -r | head -n 1)
# else
#   log_error "asdf not found. Install it by 'make installAsdf' before this."
#   exit 1
# fi

nodejs_install() {

  curl -sL install-node.now.sh/lts | bash -s -- --prefix=${HOME}/.local --yes
}

nodejs_version_func() {
  $1 --version
}

main_script $THIS nodejs_install nodejs_install version_func_node
