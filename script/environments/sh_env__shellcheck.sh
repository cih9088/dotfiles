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
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
}

version_func() {
  $1 --version | head -2 | tail -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
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
  [ -z "${VERSION}" ] && VERSION="$(list_versions | head -n 1)"

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

      if [[ ${PLATFORM} == "OSX" ]]; then
        # does not have aarch64 for apple
        ++ curl -LO "https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.darwin.x86_64.tar.xz"
        ++ tar -xvJf "shellcheck-${VERSION}.darwin.x86_64.tar.xz"

        ++ pushd shellcheck-${VERSION}
        ++ cp shellcheck ${PREFIX}/bin
        ++ popd

      elif [[ ${PLATFORM} == "LINUX" ]]; then
        ++ curl -LO "https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.linux.${ARCH}.tar.xz"
        ++ tar -xvJf "shellcheck-${VERSION}.linux.${ARCH}.tar.xz"

        ++ pushd "shellcheck-${VERSION}"
        ++ cp shellcheck "${PREFIX}/bin"
        ++ popd
      fi
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"
  local VERSION="$(list_versions | head -n 1)"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list shellcheck >/dev/null 2>&1 && ++ brew uninstall shellcheck
      elif [ "${COMMAND}" == "install" ]; then
        brew list shellcheck >/dev/null 2>&1 || ++ brew install shellcheck
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade shellcheck
      fi
      ;;
    LINUX)
      if [[ "remove update"  == *"${COMMAND}"* ]]; then
        ++ sudo rm -f /usr/local/bin/shellcheck
      fi
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        ++ curl -LO "https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.linux.${ARCH}.tar.xz"
        ++ tar -xvJf "shellcheck-${VERSION}.linux.${ARCH}.tar.xz"

        ++ pushd "shellcheck-${VERSION}"
        ++ sudo mkdir -p /usr/local/bin
        ++ sudo cp shellcheck /usr/local/bin
        ++ popd
      fi
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
