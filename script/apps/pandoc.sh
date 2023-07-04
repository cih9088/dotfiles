#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
GH="jgm/pandoc"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"

log_title "Prepare for ${THIS_HL}"
################################################################

list_versions() {
  echo "$("${DIR}/../helpers/gh_list_releases" "${GH}")" |
    sort -Vr
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
  SRC_PATH="$(find "${PREFIX}/src" -maxdepth 1 -type d -name "pandoc-*")"

  # remove
  if [[ "remove update"  == *"${COMMAND}"* ]]; then
    if [ -n "${SRC_PATH}" ]; then
      ++ pushd "${SRC_PATH}"
      while IFS= read -r line; do
        rm -rf "$line"
      done < installed.txt
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
      [[ -z "${VERSION}" || "${VERSION}" == "latest" ]] && VERSION="$(list_versions | head -n 1)"

      if [ "${PLATFORM}" == "LINUX" ]; then
        if [ "${ARCH}" == "x86_64" ]; then
          ++ curl -LO "https://github.com/jgm/pandoc/releases/download/${VERSION}/pandoc-${VERSION}-linux-amd64.tar.gz"
          ++ tar -xvzf "pandoc-${VERSION}-linux-amd64.tar.gz"
        elif [ "${ARCH}" == "aarch64" ]; then
          ++ curl -LO "https://github.com/jgm/pandoc/releases/download/${VERSION}/pandoc-${VERSION}-linux-arm64.tar.gz"
          ++ tar -xvzf "pandoc-${VERSION}-linux-arm64.tar.gz"
        fi
      elif [ "${PLATFORM}" == "OSX" ]; then
        if [ "${ARCH}" == "x86_64" ]; then
          ++ curl -LO "https://github.com/jgm/pandoc/releases/download/${VERSION}/pandoc-${VERSION}-x86_64-macOS.zip"
          ++ unzip "pandoc-${VERSION}-linux-amd64.tar.gz"
        elif [ "${ARCH}" == "aarch64" ]; then
          ++ curl -LO "https://github.com/jgm/pandoc/releases/download/${VERSION}/pandoc-${VERSION}-arm64-macOS.zip"
          ++ unzip "pandoc-${VERSION}-arm64-macOS.zip"
        fi
      fi

      ++ mkdir "${PREFIX}/src/pandoc-${VERSION}"
      for file in $(find $(readlink -f pandoc-"${VERSION}") -not -type d); do
        file_to="${file/$(readlink -f pandoc-"${VERSION}")/${PREFIX}}"
        ++ cp "$file" "$file_to"
        ++ echo "$file_to" >> "${PREFIX}/src/pandoc-${VERSION}/installed.txt"
      done
    fi
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list pandoc >/dev/null 2>&1 && ++ brew uninstall pandoc
      elif [ "${COMMAND}" == "install" ]; then
        brew list pandoc >/dev/null 2>&1 || ++ brew install pandoc
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade pandoc
      fi
      ;;
    LINUX)
      case "${PLATFORM_ID}" in
        debian|ubuntu)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove pandoc
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install pandoc
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install pandoc
          fi
          ;;
        centos|rocky)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove pandoc
          elif [ "${COMMAND}" == "install" ]; then
            if [ "$(echo "${PLATFORM_VERSION}" | awk -F . '{print $1}')" -lt 9 ]; then
              ++ sudo dnf --enablerepo=powertools -y install pandoc
            else
              ++ sudo dnf -y install epel-release
              ++ sudo dnf --enablerepo=crb -y install pandoc
            fi
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update pandoc
          fi
          ;;
      esac
      ;;
  esac
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version ""
