#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="fish-shell/fish-shell"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")" |
    grep -v '[a-zA-Z]'
}

verify_version() {
  local TARGET_VERSION="${1}"
  local AVAILABLE_VERSIONS="${2}"
  AVAILABLE_VERSIONS=$(echo "${AVAILABLE_VERSIONS}" | tr "\n\r" " ")
  [[ " ${AVAILABLE_VERSIONS} " == *" ${TARGET_VERSION} "* ]]
}

version_func() {
  $1 --version | awk '{print $3}'
}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "fish-*")"

  # remove
  if [[ "remove update" == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      # https://fishshell.com/docs/current/faq.html#uninstalling-fish
      rm -Rf "${PREFIX}"/share/fish || true
      rm -Rf "${PREFIX}"/etc/fish || true
      rm -f "${PREFIX}"/share/man/man1/fish*.1 || true
      rm -f "${PREFIX}"/bin/fish || true
      rm -f "${PREFIX}"/bin/fish_key_reader || true
      rm -f "${PREFIX}"/bin/fish_indent || true
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
  if [[ "install update" == *"${COMMAND}"* ]]; then
    if [ -z "${SRC_PATH}" ]; then
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/fish-${VERSION}.tar.xz"
      ++ tar -xvJf "fish-${VERSION}.tar.xz"

      ++ pushd "fish-${VERSION}"
      # https://github.com/fish-shell/fish-shell/issues/9032#issuecomment-1173243686
      sed -i -e '/^#include <curses.h>/{N; s/^#include <curses.h>\n#include <term.h>/${TPARM_INCLUDES}/}' cmake/ConfigureChecks.cmake
      ++ mkdir build && ++ cd build
      ++ cmake .. \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "fish-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"
  local VERSION=""

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list fish >/dev/null 2>&1 && ++ brew uninstall fish
      elif [ "${COMMAND}" == "install" ]; then
        brew list fish >/dev/null 2>&1 || ++ brew install fish
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade fish
      fi
      ;;
    LINUX)
      VERSION="$(list_versions | head -n 1)"
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove fish
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get install -y software-properties-common
            ++ sudo apt-add-repository -y "ppa:fish-shell/release-${VERSION%%.*}"
            ++ sudo apt-get -y --only-upgrade install
            ++ sudo apt-get -y install fish
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install fish
          fi
          ;;
        centos|rocky)
          if [[ "remove update"  == *"${COMMAND}"* ]]; then
            # https://fishshell.com/docs/current/faq.html#uninstalling-fish
            ++ sudo rm -Rf /usr/local/etc/fish /usr/local/share/fish
            ++ sudo rm -f /usr/local/share/man/man1/fish*.1
            ++ sudo rm -f /usr/local/bin/fish
            ++ sudo rm -f /usr/local/bin/fish_key_reader
            ++ sudo rm -f /usr/local/bin/fish_indent
          fi
          if [[ "install update"  == *"${COMMAND}"* ]]; then
            ++ curl -LO "https://github.com/${GH}/releases/download/${VERSION}/fish-${VERSION}.tar.xz"
            ++ tar -xvJf "fish-${VERSION}.tar.xz"

            ++ pushd "fish-${VERSION}"
            ++ mkdir build && ++ cd build
            ++ cmake .. -DWITH_GETTEXT=ON
            ++ make
            ++ sudo make install
            ++ popd
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
