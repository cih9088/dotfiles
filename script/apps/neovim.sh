#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="neovim/neovim"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}
THIS_CMD="nvim"

log_title "Prepare for ${THIS_HL}"

DEFAULT_VERSION="$(${DIR}/../helpers/gh_get_latest_release ${GH})"
AVAILABLE_VERSIONS="$(${DIR}/../helpers/gh_list_releases ${GH})"
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "neovim-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    # if [ -x "$(command -v ${PREFIX}/bin/nvim)" ]; then
    #   if [ ${ARCH} == "x86_64" ]; then
    #     rm -rf ${PREFIX}/bin/nvim || true
    #     rm -rf ${PREFIX}/lib/nvim || true
    #     rm -rf ${PREFIX}/share/man/man1/nvim.1 || true
    #     rm -rf ${PREFIX}/share/nvim || true
    #   elif [ ${ARCH} == "aarch64" ]; then
    #     ++ pushd ${PREFIX}/src/neovim
    #     make uninstall || true
    #     make clean || true
    #     ++ popd
    #     rm -rf ${PREFIX}/src/neovim
    #   fi
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}"
      cmake --build build/ --target uninstall || true
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

      ++ curl -LO "https://github.com/neovim/neovim/archive/refs/tags/${VERSION}.tar.gz"
      ++ tar -xvzf "${VERSION}.tar.gz"

      ++ pushd "neovim-${VERSION##v}"
      ++ make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${PREFIX}" CMAKE_BUILD_TYPE=Release
      ++ make install
      ++ popd

      ++ mv "neovim-${VERSION##v}" "${PREFIX}/src"

      # case ${PLATFORM} in
      #   OSX )
      #     if [ ${ARCH} == "X86_64" ]; then
      #       ++ curl -LO https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-macos.tar.gz
      #       ++ tar -xvzf nvim-macos.tar.gz
      #       yes | \cp -rf nvim-osx64/* ${PREFIX}/
      #     else
      #       log_error "${ARCH} not supported. Install it manually."; exit 1
      #     fi
      #     ;;
      #   LINUX )
      #     if [ ${ARCH} == "x86_64" ]; then
      #       ++ curl -LO https://github.com/neovim/neovim/releases/download/${VERSION}/nvim.appimage
      #       # https://github.com/neovim/neovim/issues/7620
      #       # https://github.com/neovim/neovim/issues/7537
      #       ++ chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract
      #       yes | \cp -rf squashfs-root/usr/bin ${PREFIX}
      #       yes | \cp -rf squashfs-root/usr/lib ${PREFIX}
      #       yes | \cp -rf squashfs-root/usr/man ${PREFIX}/share
      #       yes | \cp -rf squashfs-root/usr/share/nvim ${PREFIX}/share
      #       # yes | \cp -rf squashfs-root/usr/* ${PREFIX}
      #       # chmod u+x nvim.appimage && mv nvim.appimage nvim
      #       # cp nvim ${PREFIX}/bin
      #
      #     elif [ ${ARCH} == "aarch64" ]; then
      #       # no arm built binary
      #       # https://github.com/neovim/neovim/pull/15542
      #       ++ curl -LO "https://github.com/neovim/neovim/archive/refs/tags/${VERSION}.tar.gz"
      #       ++ tar -xvzf ${VERSION}.tar.gz
      #
      #       ++ pushd "neovim-${VERSION##v}"
      #       ++ make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${PREFIX}" CMAKE_BUILD_TYPE=Release
      #       ++ make install
      #       ++ popd
      #
      #       ++ mv "neovim-${VERSION##v}" "${PREFIX}/src"
      #     else
      #       log_error "${ARCH} not supported. Install it manually."; exit 1
      #     fi
      #     ;;
      # esac
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list neovim >/dev/null 2>&1 && ++ brew uninstall neovim
      elif [ "${COMMAND}" == "install" ]; then
        brew list neovim >/dev/null 2>&1 || ++ brew install neovim
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade neovim
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove neovim
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install neovim
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install neovim
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove neovim
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install epel-release
            ++ sudo dnf -y install neovim
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update neovim
          fi
          ;;
      esac
      ;;
  esac
}

version_func() {
  $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

verify_version() {
  $(${DIR}/../helpers/gh_check_release ${GH} ${1})
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
