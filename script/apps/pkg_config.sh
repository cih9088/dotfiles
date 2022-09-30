#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD="pkg-config"

log_title "Prepare for ${THIS_HL}"

AVAILABLE_VERSIONS="$(
  curl --silent --show-error https://pkgconfig.freedesktop.org/releases/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'pkg-config' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/pkg-config-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/pkg-config-* ]; then
      pushd ${PREFIX}/src/pkg-config-* || exit $?
      make uninstall || true
      make clean || true
      popd || exit $?
      rm -rf ${PREFIX}/src/pkg-config-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/pkg-config-* ]; then

      curl -LO https://pkgconfig.freedesktop.org/releases/pkg-config-${VERSION}.tar.gz || exit $?
      tar -xvzf pkg-config-${VERSION}.tar.gz || exit $?

      mv pkg-config-${VERSION} ${PREFIX}/src
      pushd ${PREFIX}/src/pkg-config-${VERSION}

      ./configure --prefix=${PREFIX} --enable-shared --enable-static --with-internal-glib || exit $?
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
        brew list pkg-config >/dev/null 2>&1 && brew uninstall pkg-config
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y remove pkg-config || exit $?
            ;;
          RHEL )
            sudo dnf -y remove pkg-config || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "install" ]; then
    case ${PLATFORM} in
      OSX )
        brew list pkg-config >/dev/null 2>&1 || brew install pkg-config
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y install pkg-config || exit $?
            ;;
          RHEL )
            sudo dnf -y install pkg-config || exit $?
            ;;
        esac
        ;;
    esac
  elif [ "${COMMAND}" == "update" ]; then
    case ${PLATFORM} in
      OSX )
        brew upgrade pkg-config
        ;;
      LINUX )
        case ${FAMILY} in
          DEBIAN )
            sudo apt-get -y --only-upgrade install pkg-config || exit $?
            ;;
          RHEL )
            sudo dnf -y update pkg-config || exit $?
            ;;
        esac
        ;;
    esac
  fi
}

version_func() {
  $1 --version
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script ${THIS} setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
