#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD="makeinfo"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  curl --silent --show-error https://ftp.gnu.org/gnu/texinfo/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'texinfo-[0-9]\+' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/texinfo-//' |
    sort -Vr
}

version_func() {
  $1 --version | head -1 | cut -d ' ' -f4
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "texinfo-*")"

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

      ++ curl -LO "https://ftp.gnu.org/gnu/texinfo/texinfo-${VERSION}.tar.gz"
      ++ tar -xvzf "texinfo-${VERSION}.tar.gz"

      ++ pushd "texinfo-${VERSION}"
      if [ "${VERSION}" == 6.8 ]; then
        # https://groups.google.com/g/linux.debian.bugs.dist/c/HWZb5w-kpTk
        ++ curl -LO https://src.fedoraproject.org/rpms/texinfo/raw/rawhide/f/texinfo-6.8-undo-gnulib-nonnul.patch
        ++ git apply texinfo-6.8-undo-gnulib-nonnul.patch
      fi
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "texinfo-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list texinfo >/dev/null 2>&1 && ++ brew uninstall texinfo
      elif [ "${COMMAND}" == "install" ]; then
        brew list texinfo >/dev/null 2>&1 || ++ brew install texinfo
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade texinfo
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove texinfo
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install texinfo
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install texinfo
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove texinfo
          elif [ "${COMMAND}" == "install" ]; then
            local crb_name="crb"
            if [ "$(echo "${PLATFORM_VERSION}" | awk -F . '{print $1}')" -lt 9 ]; then
              crb_name="powertools"
            fi
            ++ sudo dnf --enablerepo=$crb_name -y install texinfo
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update texinfo
          fi
          ;;
      esac
      ;;
  esac

}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
