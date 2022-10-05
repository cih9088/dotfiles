#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD="iconv"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/gnu/libiconv/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libiconv-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/libiconv-* ]; then
      pushd ${PREFIX}/src/libiconv-* || exit $?
      make uninstall || true
      make clean || true
      popd || exit $?
      rm -rf ${PREFIX}/src/libiconv-*
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
    if [ ! -d "${PREFIX}"/src/libiconv-* ]; then
      [ -z $VERSION ] && VERSION=${DEFAULT_VERSION}

      curl -LO https://ftp.gnu.org/gnu/libiconv/libiconv-${VERSION}.tar.gz || exit $?
      tar -xvzf libiconv-${VERSION}.tar.gz || exit $?

      mv libiconv-${VERSION} ${PREFIX}/src
      pushd ${PREFIX}/src/libiconv-${VERSION} || exit $?

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
        brew list libiconv >/dev/null 2>&1 && brew uninstall libiconv
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y remove libc6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y remove glibc-devel || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "install" ]; then
    case ${PLATFORM} in
      OSX )
        brew list libiconv >/dev/null 2>&1 || brew install libiconv
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y install libc6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y install glibc-devel || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "update" ]; then
    case ${PLATFORM} in
      OSX )
        brew upgrade libiconv
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y --only-upgrade install libc6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y update glibc-devel || exit $?
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

is_installed() {
  [[ $(command -v iconv) ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version is_installed
