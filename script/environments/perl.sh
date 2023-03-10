#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  if command -v asdf > /dev/null; then
    asdf plugin list 2>/dev/null | grep -q perl || asdf plugin add perl >&3 2>&4
    # 'which' command may not be installed by default
    sed -i -e 's/which tac/type -ap tac/' "$ASDF_DIR/plugins/perl/bin/list-all"
    asdf list all perl | sort -Vr
  else
    # even number is stable version
    curl --silent --show-error https://www.cpan.org/src/5.0/ |
      ${DIR}/../helpers/parser_html 'a' |
      grep 'perl-[0-9.]\+.tar.gz"' |
      awk '{print $4}' |
      sed -e 's/.tar.gz//' -e 's/perl-//' |
      awk -F '.' '{if ($2 % 2 == 0) {print $0}}' |
      sort -Vr
  fi
}

version_func() {
  $1 --version | grep -o 'v[0-9.]\+'
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

  if command -v asdf > /dev/null; then
    log_info "Note that ${THIS_HL} would be installed using asdf."
    from_asdf "$COMMAND" "$VERSION"
  else
    log_info "Note that ${THIS_HL} would be installed from source."
    from_source "$COMMAND" "$VERSION"
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list perl >/dev/null 2>&1 && ++ brew uninstall perl
      elif [ "${COMMAND}" == "install" ]; then
        brew list perl >/dev/null 2>&1 || ++ brew install perl
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade perl
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove perl
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install perl
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install perl
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove perl
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install perl
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update perl
          fi
          ;;
      esac
      ;;
  esac
}

from_source() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="$(list_versions | head -n 1)"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "perl-*")"

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

      ++ curl -LO "https://www.cpan.org/src/5.0/perl-${VERSION}.tar.gz"
      ++ tar -xvzf "perl-${VERSION}.tar.gz"

      ++ pushd "perl-${VERSION}"
      ++ ./Configure -des -Dprefix="${PREFIX}" -Dusethreads
      ++ make
      ++ make install
      ++ popd

      ++ mv "perl-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

from_asdf() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION="latest"

  asdf plugin list 2>/dev/null | grep -q perl || asdf plugin add perl >&3 2>&4
  # 'which' command may not be installed by default
  sed -i -e 's/which tac/type -ap tac/' "$ASDF_DIR/plugins/perl/bin/list-all"

  if [ "${VERSION}" == "latest" ]; then
    VERSION=$(asdf latest perl)
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ asdf uninstall perl "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ asdf install perl "${VERSION}"
    ++ asdf global perl "${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func
