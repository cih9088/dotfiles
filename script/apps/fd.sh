#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="sharkdp/fd"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/fd" ]; then
      rm -f "${PREFIX}/bin/fd" || true
      rm -f "${PREFIX}/share/man/man1/fd.1.gz" || true
      rm -f "${PREFIX}/share/bash-completion/completions/fd" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/fd" ]; then

      case ${PLATFORM} in
        OSX )
          # does not have aarch64 for apple
          ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/fd-${VERSION}-x86_64-apple-darwin.tar.gz"
          ++ tar -xvzf "fd-${VERSION}-x86_64-apple-darwin.tar.gz"

          ++ pushd "fd-${VERSION}-x86_64-apple-darwin"
          ++ cp fd "${PREFIX}/bin"
          ++ gzip fd.1
          ++ cp fd.1.gz "${PREFIX}/share/man/man1"
          ++ cp autocomplete/fd.bash "${PREFIX}/share/bash-completion/completions/fd"
          ++ popd
          ;;
        LINUX )
          ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/fd-${VERSION}-${ARCH}-unknown-linux-gnu.tar.gz"
          ++ tar -xvzf "fd-${VERSION}-${ARCH}-unknown-linux-gnu.tar.gz"

          ++ pushd "fd-${VERSION}-${ARCH}-unknown-linux-gnu"
          ++ cp fd "${PREFIX}/bin"
          ++ gzip fd.1
          ++ cp fd.1.gz "${PREFIX}/share/man/man1"
          ++ cp autocomplete/fd.bash "${PREFIX}/share/bash-completion/completions/fd"
          ++ popd
          ;;
      esac
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list fd >/dev/null 2>&1 && ++ brew uninstall fd
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list fd >/dev/null 2>&1 || ++ brew install fd
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade fd
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove fd-find
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install fd-find
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install fd-find
          fi
          ;;
        RHEL)
          if [[ "remove update"  == *"${COMMAND}"* ]]; then
            ++ sudo rm -f /usr/local/bin/fd
            ++ sudo rm -f /usr/local/share/man/man1/fd.1.gz
            ++ sudo rm -f /usr/local/share/bash-completion/completions/fd
          fi
          if [[ "install update"  == *"${COMMAND}"* ]]; then
            ++ curl -LO "https://github.com/${GH}/releases/download/${DEFAULT_VERSION}/fd-${DEFAULT_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz"
            ++ tar -xvzf "fd-${DEFAULT_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz"

            ++ pushd "fd-${DEFAULT_VERSION}-${ARCH}-unknown-linux-gnu"
            ++ sudo mkdir -p /usr/local/bin
            ++ sudo cp fd /usr/local/bin/
            ++ gzip fd.1
            ++ chown root:root fd.1.gz
            ++ sudo cp fd.1.gz /usr/local/share/man/man1
            ++ sudo mkdir -p /usr/local/share/bash-completion/completions
            ++ sudo cp autocomplete/fd.bash /usr/local/share/bash-completion/completions/fd
            ++ popd
          fi
          ;;
      esac
      ;;
  esac

}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
