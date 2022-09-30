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
  curl --silent --show-error https://gnuftp.uib.no/help2man/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/help2man-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/help2man-* ]; then
      ++ pushd ${PREFIX}/src/help2man-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/src/help2man-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/help2man-* ]; then

      ++ curl -LO "https://gnuftp.uib.no/help2man/help2man-${VERSION}.tar.gz"
      ++ tar -xvzf "help2man-${VERSION}.tar.gz"

      ++ pushd "help2man-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make
      ++ make install
      ++ popd

      ++ mv "help2man-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list help2man >/dev/null 2>&1 && ++ brew uninstall help2man
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list help2man >/dev/null 2>&1 || ++ brew install help2man
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade help2man
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove help2man
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install help2man
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install help2man
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove help2man
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install help2man
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update help2man
          fi
          ;;
      esac
      ;;
  esac
}

version_func() {
  $1 --version | grep 'GNU' | awk '{print $3}'
}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
