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
  curl --silent --show-error https://www.openldap.org/software/download/OpenLDAP/openldap-release/ |
    ${DIR}/../helpers/parser_html 'a' |
    grep -E 'openldap-[0-9.]+.tgz"' |
    awk '{print $4}' |
    sed -e 's/.tgz//' -e 's/openldap-//' |
    sort -Vr)"
DEFAULT_VERSION=$(echo "$AVAILABLE_VERSIONS" | head -n 1 )
################################################################

setup_func_local() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  local SRC_PATH=""
  [ -z "${VERSION}" ] && VERSION="${DEFAULT_VERSION}"
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "openldap-*")"

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

      ++ curl -LO "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${VERSION}.tgz"
      ++ tar -xvzf "openldap-${VERSION}.tgz"

      ++ pushd "openldap-${VERSION}"
      ++ ./configure --prefix="${PREFIX}"
      ++ make depend
      ++ make
      ++ make install
      ++ popd

      mv "openldap-${VERSION}" "${PREFIX}/src"
    fi
  fi
}

setup_func_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list openldap >/dev/null 2>&1 && ++ brew uninstall openldap
      elif [ "${COMMAND}" == "install" ]; then
        brew list openldap >/dev/null 2>&1 || ++ brew install openldap
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade openldap
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove libldap-dev
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install libldap-dev
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install libldap-dev
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove openldap-devel
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install openldap-devel
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update openldap-devel
          fi
          ;;
      esac
      ;;
  esac

}

verify_version() {
  [[ "$AVAILABLE_VERSIONS" == *"${1}"* ]]
}

main_script "${THIS}" setup_func_local setup_func_system "" \
  "${DEFAULT_VERSION}" "${AVAILABLE_VERSIONS}" verify_version

