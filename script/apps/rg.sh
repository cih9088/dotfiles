#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="BurntSushi/ripgrep"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

if [ "${ARCH}" = "aarch64" ]; then
  # Original repo of ripgrep is https://github.com/BurntSushi/ripgrep
  # but it has limited number of pre-built binaries.
  # This script will download pre-built binary from microsoft.
  GH="microsoft/ripgrep-prebuilt"
fi

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
}

version_func_rg() {
  $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
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
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/rg" ]; then
      rm -rf "${PREFIX}/bin/rg" || true
      rm -rf "${PREFIX}/share/man/man1/rg.1.gz" || true
      rm -rf "${PREFIX}/share/bash-completion/completions/rg" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/rg" ]; then

      case ${PLATFORM} in
        OSX )
          if [ "${ARCH}" = "aarch64" ]; then
            # prebuilt ripgrep from microsoft repository
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz"
            ++ tar -xvzf "ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz"
            ++ cp -rf rg "${PREFIX}/bin"
          else
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz"
            ++ tar -xvzf "ripgrep-${VERSION}-${ARCH}-apple-darwin.tar.gz"

            ++ pushd "ripgrep-${VERSION}-${ARCH}-unknown-linux-musl"
            ++ cp rg "${PREFIX}/bin"
            ++ gzip doc/rg.1
            ++ cp doc/rg.1.gz "${PREFIX}/share/man/man1"
            ++ cp complete/rg.bash "${PREFIX}/share/bash-completion/completions/rg"
            ++ popd
          fi
          ;;
        LINUX )
          if [ "${ARCH}" = "aarch64" ]; then
            # prebuilt ripgrep from microsoft repository
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
            ++ tar -xvzf "ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
            ++ cp -rf rg "${PREFIX}/bin"
          else
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
            ++ tar -xvzf "ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"

            ++ pushd "ripgrep-${VERSION}-${ARCH}-unknown-linux-musl"
            ++ cp rg "${PREFIX}/bin"
            ++ gzip doc/rg.1
            ++ cp doc/rg.1.gz "${PREFIX}/share/man/man1"
            ++ cp complete/rg.bash "${PREFIX}/share/bash-completion/completions/rg"
            ++ popd
          fi
          ;;
      esac
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"
  local VERSION="$(list_versions | head -n 1)"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list ripgrep >/dev/null 2>&1 && ++ brew uninstall ripgrep
      elif [ "${COMMAND}" == "install" ]; then
        brew list ripgrep >/dev/null 2>&1 || ++ brew install ripgrep
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade ripgrep
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove ripgrep
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install ripgrep
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install ripgrep
          fi
          ;;
        RHEL)
          if [[ "remove update"  == *"${COMMAND}"* ]]; then
            sudo rm -f /usr/local/bin/rg || true
            sudo rm -f /usr/local/share/man/man1/rg.1.gz || true
            sudo rm -f /usr/local/share/bash-completion/completions/rg || true
          fi
          if [[ "install update"  == *"${COMMAND}"* ]]; then
            if [ "${ARCH}" = "aarch64" ]; then
              # prebuilt ripgrep from microsoft repository
              ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
              ++ tar -xvzf "ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
              ++ sudo cp -rf rg /usr/local/bin/
              ++ sudo chmod +x /usr/local/bin/rg
            else
              ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
              ++ tar -xvzf "ripgrep-${VERSION}-${ARCH}-unknown-linux-musl.tar.gz"

              ++ pushd "ripgrep-${VERSION}-${ARCH}-unknown-linux-musl"
              ++ sudo mkdir -p /usr/local/bin
              ++ sudo cp rg /usr/local/bin/
              ++ sudo chmod +x /usr/local/bin/rg
              ++ gzip doc/rg.1
              ++ sudo chown root:root doc/rg.1.gz
              ++ sudo cp doc/rg.1.gz /usr/local/share/man/man1
              ++ sudo mkdir -p /usr/local/share/bash-completion/completions
              ++ sudo cp complete/rg.bash /usr/local/share/bash-completion/completions/rg
              ++ popd
            fi
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
