#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
###############################################################

list_versions() {
  curl --silent --show-error https://sourceforge.net/projects/zsh/files/zsh/ |
    ${DIR}/../helpers/parser_html 'span' |
    grep 'class="name"' |
    awk '{print $4}' |
    grep -v '[a-z]' |
    sort -Vr
}

version_func() {
  $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
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
  local SRC_PATH=""
  [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "zsh-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}"
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf "${SRC_PATH}"
      SRC_PATH=""
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ -z "${SRC_PATH}" ]; then

      # download latest version and specify version
      if [[ ${VERSION} == "latest" ]]; then
        ++ curl -L https://sourceforge.net/projects/zsh/files/latest/download \
          -o "zsh-${VERSION}.tar.xz"
        ++ tar -xvJf "zsh-${VERSION}.tar.xz"
        VERSION="$(find . -type d -name 'zsh-*' -exec basename {} \; | sed 's/zsh-//')"
      else
        ++ curl -L "https://sourceforge.net/projects/zsh/files/zsh/${VERSION}/zsh-${VERSION}.tar.xz/download" \
          -o "zsh-${VERSION}.tar.xz"
        ++ tar -xvJf "zsh-${VERSION}.tar.xz"
      fi

      ++ pushd "zsh-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "zsh-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list zsh >/dev/null 2>&1 && ++ brew uninstall zsh
      elif [ "${COMMAND}" == "install" ]; then
        brew list zsh >/dev/null 2>&1 || ++ brew install zsh
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade zsh
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove zsh
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install zsh
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install zsh
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove zsh
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install zsh
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update zsh
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
