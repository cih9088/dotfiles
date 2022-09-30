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
  curl --silent --show-error https://ftp.gnu.org/gnu/libtasn1/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep 'tar.gz\"' | grep -v 'libasn1' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/libtasn1-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/libtasn1-* ]; then
      pushd ${PREFIX}/src/libtasn1-* || exit $?
      make uninstall || true
      make clean || true
      popd || exit $?
      rm -rf ${PREFIX}/src/libtasn1-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/libtasn1-* ]; then

      curl -LO https://ftp.gnu.org/gnu/libtasn1/libtasn1-${VERSION}.tar.gz || exit $?
      tar -xvzf libtasn1-${VERSION}.tar.gz || exit $?

      mv libtasn1-${VERSION} ${PREFIX}/src
      pushd ${PREFIX}/src/libtasn1-${VERSION} || exit $?

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
        brew list libtasn1 >/dev/null 2>&1 && brew uninstall libtasn1
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y remove libtans1-6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y remove libtasn1-devel || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "install" ]; then
    case ${PLATFORM} in
      OSX )
        brew list libtasn1 >/dev/null 2>&1 || brew install libtasn1
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y install libtans1-6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y install libtasn1-devel || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "update" ]; then
    case ${PLATFORM} in
      OSX )
        brew upgrade libtasn1
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y --only-upgrade install libtans1-6-dev || exit $?
            ;;
          RHEL )
            sudo dnf -y update libtasn1-devel || exit $?
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
