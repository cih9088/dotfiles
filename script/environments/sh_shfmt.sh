#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=sh-env
GH="mvdan/sh"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=shfmt

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_shfmt_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=$DEFAULT_VERSION

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/shfmt" ]; then
      rm -rf "${PREFIX}/bin/shfmt" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/shfmt" ]; then

      if [ "${ARCH}" == "x86_64" ]; then
        _ARCH=amd64
      elif [ "${ARCH}" == "aarch64" ]; then
        _ARCH=arm64
      fi

      if [[ ${PLATFORM} == "OSX" ]]; then
        # does not have aarch64 for apple
        curl -LO https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_darwin_${_ARCH} || exit $?
        chmod +x shfmt_${VERSION}_darwin_${_ARCH}
        \cp -rf shfmt_${VERSION}_darwin_${_ARCH} ${PREFIX}/bin/shfmt
      elif [[ ${PLATFORM} == "LINUX" ]]; then
        curl -LO https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_linux_${_ARCH} || exit $?
        chmod +x shfmt_${VERSION}_linux_${_ARCH}
        \cp -rf shfmt_${VERSION}_linux_${_ARCH} ${PREFIX}/bin/shfmt
      fi
    fi
  fi
}

setup_func_shfmt_system() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    case ${PLATFORM} in
      OSX )
        brew list shfmt >/dev/null 2>&1 && brew uninstall shfmt
        ;;
      LINUX )
        log_error "No package in repository. Please install it in local mode"
        exit 1
        ;;
    esac
  elif [ "${COMMAND}" == "install" ]; then
    case ${PLATFORM} in
      OSX )
        brew list shfmt >/dev/null 2>&1 || brew install shfmt
        ;;
      LINUX )
        log_error "No package in repository. Please install it in local mode"
        exit 1
        ;;
    esac
  elif [ "${COMMAND}" == "update" ]; then
    case ${PLATFORM} in
      OSX )
        brew upgrade shfmt
        ;;
      LINUX )
        log_error "No package in repository. Please install it in local mode"
        exit 1
        ;;
    esac
  fi
}

version_func_shfmt() {
  $1 -version
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_shfmt_local setup_func_shfmt_system version_func_shfmt \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

