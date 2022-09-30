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

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/gnu/texinfo/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'texinfo-[0-9]\+' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/texinfo-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/texinfo-* ]; then
      pushd ${PREFIX}/src/texinfo-* || exit $?
      make uninstall || true
      make clean || true
      popd || exit $?
      rm -rf ${PREFIX}/src/texinfo-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/texinfo-* ]; then

      curl -LO https://ftp.gnu.org/gnu/texinfo/texinfo-${VERSION}.tar.gz || exit $?
      tar -xvzf texinfo-${VERSION}.tar.gz || exit $?

      mv texinfo-${VERSION} ${PREFIX}/src
      pushd ${PREFIX}/src/texinfo-${VERSION} || exit $?

      ./configure --prefix=${PREFIX} || exit $?
      make || exit $?
      make install || exit $?

      popd || exit $?
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    case ${PLATFORM} in
      OSX )
        brew list texinfo >/dev/null 2>&1 && brew uninstall texinfo
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y remove libc6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y remove texinfo-devel || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "install" ]; then
    case ${PLATFORM} in
      OSX )
        brew list texinfo >/dev/null 2>&1 || brew install texinfo
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y install libc6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y install texinfo-devel || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "update" ]; then
    case ${PLATFORM} in
      OSX )
        brew upgrade texinfo
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y --only-upgrade install libc6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y update texinfo-devel || exit $?
            ;;
        esac
        ;;
    esac
  fi
}

version_func() {
  $1 --version | head -1 | cut -d ' ' -f4
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
