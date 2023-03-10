#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  curl --silent --show-error https://www.sourceware.org/pub/bzip2/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -v 'latest' | grep -v 'bzip-' | grep 'tar.gz\"' |
    awk '{print $4}' |
    sed -e 's/.tar.gz//' -e 's/bzip2-//' |
    sort -Vr
}

version_func() {
  $1 --help 2>&1 | grep Version | awk '{for(i=7;i<=NF;++i) printf $i " "; printf "\n"}'
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
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="$(list_versions | head -n 1)"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "bzip2-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}"
      make uninstall || true
      make clean || true
      ++ popd

      rm -f "${PREFIX}/bin/bzip2-shared" || true
      rm -f "${PREFIX}/lib/libbz2.so*" || true

      rm -f "${PREFIX}/bin/bzip2" || true
      rm -f "${PREFIX}/bin/bunzip2" || true
      rm -f "${PREFIX}/bin/bzcat" || true
      rm -f "${PREFIX}/bin/bzip2recover" || true
      rm -f "${PREFIX}/share/man/man1/bzip2.1" || true
      rm -f "${PREFIX}/include/bzlib.h" || true
      rm -f "${PREFIX}/lib/libbz2.a" || true
      rm -f "${PREFIX}/bin/bzgrep" || true
      rm -f "${PREFIX}/bin/bzegrep" || true
      rm -f "${PREFIX}/bin/bzfgrep" || true
      rm -f "${PREFIX}/bin/bzmore" || true
      rm -f "${PREFIX}/bin/bzless" || true
      rm -f "${PREFIX}/bin/bzdiff" || true
      rm -f "${PREFIX}/bin/bzcmp" || true
      rm -f "${PREFIX}/share/man/man1/bzgrep.1" || true
      rm -f "${PREFIX}/share/man/man1/bzmore.1" || true
      rm -f "${PREFIX}/share/man/man1/bzdiff.1" || true
      rm -f "${PREFIX}/share/man/man1/bzegrep.1" || true
      rm -f "${PREFIX}/share/man/man1/bzfgrep.1" || true
      rm -f "${PREFIX}/share/man/man1/bzless.1" || true
      rm -f "${PREFIX}/share/man/man1/bzcmp.1" || true

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

      ++ curl -LO "https://www.sourceware.org/pub/bzip2/bzip2-${VERSION}.tar.gz"
      ++ tar -xvzf "bzip2-${VERSION}.tar.gz"

      ++ pushd "bzip2-${VERSION}"
      ++ sed -i -e "\"s|\$(PREFIX)/man|\$(PREFIX)/share/man|\"" Makefile
      ++ make install PREFIX="${PREFIX}"
      # Build shared library
      ++ make clean
      ++ make -f Makefile-libbz2_so
      ++ mv bzip2-shared "${PREFIX}/bin"
      ++ mv "libbz2.so.${VERSION}" "${PREFIX}/lib"

      # link libbz2.so forcefully
      ++ pushd "${PREFIX}/lib"
      ++ ln -snf "libbz2.so.${VERSION}" "libbz2.so.${VERSION%%.*}"
      ++ ln -snf "libbz2.so.${VERSION%%.*}" libbz2.so

      ++ popd && ++ popd

      ++ mv "bzip2-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list bzip2 >/dev/null 2>&1 && ++ brew uninstall bzip2
      elif [ "${COMMAND}" == "install" ]; then
        brew list bzip2 >/dev/null 2>&1 || ++ brew install bzip2
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade bzip2
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libbz2-dev bzip2
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libbz2-dev bzip2
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libbz2-dev bzip2
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove bzip2-devel bzip2
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install bzip2-devel bzip2
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update bzip2-devel bzip2
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
