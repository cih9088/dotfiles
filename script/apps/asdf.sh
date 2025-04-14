#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="asdf-vm/asdf"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")"
}

version_func() {
  $1 version
}

# https://asdf-vm.com/guide/upgrading-to-v0-16.html
setup_for_local_0_16_after() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -f "${PREFIX}/bin/asdf" ]; then
      rm -rf "${PREFIX}/bin/asdf" || true
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -f "${PREFIX}/bin/asdf" ]; then
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"
      case ${PLATFORM} in
        OSX )
          if [ "${ARCH}" = "aarch64" ]; then
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/asdf-${VERSION}-darwin-arm64.tar.gz"
            ++ tar -xvzf "asdf-${VERSION}-darwin-arm64.tar.gz"
            ++ cp -rf asdf "${PREFIX}/bin"
          else
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/asdf-${VERSION}-darwin-amd64.tar.gz"
            ++ tar -xvzf "asdf-${VERSION}-darwin-amd64.tar.gz"
            ++ cp -rf asdf "${PREFIX}/bin"
          fi
          ;;
        LINUX )
          if [ "${ARCH}" = "aarch64" ]; then
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/asdf-${VERSION}-linux-arm64.tar.gz"
            ++ tar -xvzf "asdf-${VERSION}-linux-arm64.tar.gz"
            ++ cp -rf asdf "${PREFIX}/bin"
          else
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/asdf-${VERSION}-linux-amd64.tar.gz"
            ++ tar -xvzf "asdf-${VERSION}-linux-amd64.tar.gz"
            ++ cp -rf asdf "${PREFIX}/bin"
          fi
          ;;
      esac
    fi
  fi
}

setup_for_local_0_16_before() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
      chown -R $(whoami) ${HOME}/.asdf
      rm -rf ${HOME}/.asdf || true
    fi
  elif [ "${COMMAND}" == "install" ]; then
    if [ ! -f "${HOME}/.asdf/asdf.sh" ]; then
      ++ git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf
      ++ pushd ${HOME}/.asdf
      ++ git checkout "$(git describe --abbrev=0 --tags)"
      ++ popd

      # direnv
      . $HOME/.asdf/asdf.sh
      ++ asdf plugin add direnv
      ++ asdf direnv setup --shell zsh --version latest
      # ++ asdf direnv setup --shell bash --version latest
      # ++ asdf direnv setup --shell fish --version latest
      ++ asdf set -u direnv latest
    fi
  elif [ "${COMMAND}" == "update" ]; then
    if [ -f "${HOME}/.asdf/asdf.sh" ]; then
      . $HOME/.asdf/asdf.sh
      ++ asdf update
      ++ asdf plugin update --all
    else
      log_error "${THIS_HL} is not installed. Please install it before update it."
      exit 1
    fi
  fi
}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  setup_for_local_0_16_after $COMMAND $VERSION
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list asdf >/dev/null 2>&1 && ++ brew uninstall asdf
      elif [ "${COMMAND}" == "install" ]; then
        brew list asdf >/dev/null 2>&1 || ++ brew install asdf
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade asdf
      fi
      ;;
    LINUX)
      log_info "Not able to ${COMMAND} ${THIS} systemwide."
      setup_for_local "${COMMAND}"
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  "" "" version_func
