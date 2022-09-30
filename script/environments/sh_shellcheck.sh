#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=sh-env
GH="koalaman/shellcheck"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. "${DIR}/../helpers/common.sh"
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=shellcheck

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_shellcheck_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/shellcheck" ]; then
      rm -rf "${PREFIX}/bin/shellcheck" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/shellcheck" ]; then
      [ -z "${VERSION}" ] && VERSION=$DEFAULT_VERSION

      if [[ ${PLATFORM} == "OSX" ]]; then
        # does not have aarch64 for apple
        curl -LO https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.darwin.x86_64.tar.xz || exit $?
        tar -xvJf shellcheck-${VERSION}.darwin.x86_64.tar.xz || exit $?

        pushd shellcheck-${VERSION}
        yes | \cp -rf shellcheck ${PREFIX}/bin
        popd

      elif [[ ${PLATFORM} == "LINUX" ]]; then
        curl -LO https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.linux.${ARCH}.tar.xz || exit $?
        tar -xvJf shellcheck-${VERSION}.linux.${ARCH}.tar.xz || exit $?

        pushd shellcheck-${VERSION}
        yes | \cp -rf shellcheck ${PREFIX}/bin
        popd
      fi
    fi
  fi
}

setup_func_shellcheck_system() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    case ${PLATFORM} in
      OSX )
        brew list shellcheck >/dev/null 2>&1 && brew uninstall shellcheck
        ;;
      LINUX )
        log_error "No package in repository. Please install it in local mode"
        exit 1
        ;;
    esac
  elif [ "${COMMAND}" == "install" ]; then
    case ${PLATFORM} in
      OSX )
        brew list shellcheck >/dev/null 2>&1 || brew install shellcheck
        ;;
      LINUX )
        log_error "No package in repository. Please install it in local mode"
        exit 1
        ;;
    esac
  elif [ "${COMMAND}" == "update" ]; then
    case ${PLATFORM} in
      OSX )
        brew upgrade shellcheck
        ;;
      LINUX )
        log_error "No package in repository. Please install it in local mode"
        exit 1
        ;;
    esac
  fi
}

version_func_shellcheck() {
  $1 --version | head -2 | tail -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_shellcheck_local setup_func_shellcheck_system version_func_shellcheck \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
