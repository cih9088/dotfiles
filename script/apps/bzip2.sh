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
  curl --silent --show-error https://www.sourceware.org/pub/bzip2/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep -v 'bzip-' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/bzip2-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -d ${PREFIX}/src/bzip2-* ]; then
      ++ pushd ${PREFIX}/src/bzip2-*
      make uninstall || true
      make clean || true
      ++ popd
      rm -rf ${PREFIX}/bin/bzip2-shared || true
      rm -rf ${PREFIX}/lib/libbz2.so* || true
      rm -rf ${PREFIX}/lib/libbz2.so || true
      rm -rf ${PREFIX}/src/bzip2-*
    else
      if [ "${COMMAND}" == "update" ]; then
        log_error "${THIS_HL} is not installed. Please install it before update it."
        exit 1
      fi
    fi
  fi

  # install
  if [[ "install update"  == *"${COMMAND}"* ]]; then
    if [ ! -d "${PREFIX}"/src/bzip2-* ]; then

      ++ curl -LO "https://www.sourceware.org/pub/bzip2/bzip2-${VERSION}.tar.gz"
      ++ tar -xvzf "bzip2-${VERSION}.tar.gz"

      ++ pushd "bzip2-${VERSION}"
      ++ sed -i -e "s|\$(PREFIX)/man|\$(PREFIX)/share/man|" Makefile
      ++ make install PREFIX="${PREFIX}"
      # Build shared library
      ++ make clean
      ++ make -f Makefile-libbz2_so
      ++ mv bzip2-shared "${PREFIX}/bin"
      ++ mv libbz2.so* "${PREFIX}/lib"

      # link libbz2.so forcefully
      ++ pushd "${PREFIX}/lib"
      ++ ln -snf "libbz2.so.${VERSION}" libbz2.so

      ++ popd && ++ popd

      ++ mv "bzip2-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        ++ brew list bzip2 >/dev/null 2>&1 && ++ brew uninstall bzip2
      elif [ "${COMMAND}" == "install" ]; then
        ++ brew list bzip2 >/dev/null 2>&1 || ++ brew install bzip2
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade bzip2
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libbz2-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libbz2-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libbz2-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove bzip2-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install bzip2-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update bzip2-devel
          fi
          ;;
      esac
      ;;
  esac
}

version_func() {
  $1 --help 2>&1 | grep Version | awk '{for(i=7;i<=NF;++i) printf $i " "; printf "\n"}'
}


verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system version_func \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version
