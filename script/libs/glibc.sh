#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://ftp.gnu.org/pub/gnu/glibc/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'glibc-[0-9]\+' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/glibc-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/glibc-* ]; then
      pushd ${PREFIX}/src/glibc-* || exit $?
      make uninstall || true
      make clean || true
      popd || exit $?
      rm -rf ${PREFIX}/src/glibc-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/glibc-* ]; then

      curl -LO https://ftp.gnu.org/pub/gnu/glibc/glibc-${VERSION}.tar.gz || exit $?
      tar -xvzf glibc-${VERSION}.tar.gz || exit $?

      mv glibc-${VERSION} ${PREFIX}/src
      pushd ${PREFIX}/src/glibc-${VERSION} || exit $?

      curl -LO https://ftp.gnu.org/pub/gnu/glibc/glibc-linuxthreads-2.5.tar.bz2 || exit $?
      tar -xvf glibc-linuxthreads-2.5.tar.bz2

      mkdir build || exit $?
      pushd build || exit $?

      ../configure --prefix=${PREFIX} --enable-add-ons=linuxthreads || exit $?
      make || exit $?
      make install || exit $?

      popd || exit $?
      popd || exit $?
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  if [ "${COMMAND}" == "remove" ]; then
    case ${PLATFORM} in
      OSX )
        brew list glibc >/dev/null 2>&1 && brew uninstall glibc
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
        brew list glibc >/dev/null 2>&1 || brew install glibc
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
        brew upgrade glibc
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

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

