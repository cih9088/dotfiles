#!/usr/bin/env bash
# based on https://gist.github.com/ryin/3106801#gistcomment-2191503
# tmux will be installed in ${PREFIX}/bin if you specify to install without root access


################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="tmux/tmux"

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
  $1 -V | awk '{print $2}'
}

verify_version() {
  local TARGET_VERSION="${1}"
  local AVAILABLE_VERSIONS="${2}"
  AVAILABLE_VERSIONS=$(echo "${AVAILABLE_VERSIONS}" | tr "\n\r" " ")
  [[ " ${AVAILABLE_VERSIONS} " == *" ${TARGET_VERSION} "* ]]
}

install_tmux_terminfo() {
  local MODE=$1

  # https://github.com/htop-dev/htop/issues/251#issuecomment-719080271
  ++ curl -LO https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color
  if [ "${MODE}" == "system" ]; then
    ++ sudo tic -x tmux-256color
  else
    ++ tic -x -o "${HOME}/.terminfo" tmux-256color
  fi

}

setup_for_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "tmux-*")"

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
    install_tmux_terminfo "local"
    if [ -z "${SRC_PATH}" ]; then
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      ++ curl -LO "https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz"
      ++ tar -xvzf "tmux-${VERSION}.tar.gz"

      ++ pushd "tmux-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "tmux-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        # https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95?permalink_comment_id=4531363#gistcomment-4531363
        local ncdir=$(brew --prefix)/opt/ncurses
        # local terms=(alacritty-direct alacritty tmux tmux-256color)
        local terms=(tmux tmux-256color)
        for x in ${terms[@]} ; do
          $ncdir/bin/infocmp -x -A $ncdir/share/terminfo $x > ${x}.src &&
            sed -i '' 's|pairs#0x10000|pairs#32767|' ${x}.src &&
            /usr/bin/tic -x -o "${HOME}/.terminfo" ${x}.src &&
            rm -f ${x}.src
        done
      fi
      if [ "${COMMAND}" == "remove" ]; then
        # brew list reattach-to-user-namespace >/dev/null 2>&1 && ++ brew uninstall reattach-to-user-namespace
        brew list tmux >/dev/null 2>&1 && ++ brew uninstall tmux
      elif [ "${COMMAND}" == "install" ]; then
        brew list tmux >/dev/null 2>&1 || ++ brew install tmux
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade tmux
      fi
      ;;
    LINUX)
      if [[ "install update"  == *"${COMMAND}"* ]]; then
        install_tmux_terminfo "system"
      fi
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove tmux
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install tmux
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install tmux
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove tmux
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install tmux
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update tmux
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
