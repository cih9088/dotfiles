#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
THIS_CMD="python3"

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${CUR_DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include/ncurses"
################################################################

list_versions() {
  if command -v pyenv > /dev/null; then
    pyenv install -l | grep -v '[a-zA-Z]' | sed 's/ //' | sort -Vr
  elif command -v asdf > /dev/null; then
    asdf plugin list 2>/dev/null | grep -q python || asdf plugin add python >&3 2>&4
    asdf list all python | grep -v '[a-zA-Z]' | sort -Vr
  fi
}

version_func() {
  $1 --version 2>&1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
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

  if command -v pyenv > /dev/null; then
    # install latest plugin if not installed
    [ ! -d ${PYENV_ROOT}/plugins/xxenv-latest ] && \
      git clone https://github.com/momo-lab/xxenv-latest.git ${PYENV_ROOT}/plugins/xxenv-latest
    eval "$(pyenv init -)"

    log_info "Note that ${THIS_HL} would be installed using pyenv."
    from_pyenv "$COMMAND" "$VERSION"
  elif command -v asdf > /dev/null; then
    log_info "Note that ${THIS_HL} would be installed using asdf."
    from_asdf "$COMMAND" "$VERSION"
  else
    log_error "Install from source is not implemented."
    exit 1
  fi
}

setup_for_system() {
  local COMMAND="${1:-skip}"

  case "${PLATFORM}" in
    OSX)
      if [ "${COMMAND}" == "remove" ]; then
        brew list python3 >/dev/null 2>&1 && ++ brew uninstall python3
      elif [ "${COMMAND}" == "install" ]; then
        brew list python3 >/dev/null 2>&1 || ++ brew install python3
      elif [ "${COMMAND}" == "update" ]; then
        ++ brew upgrade python3
      fi
      ;;
    LINUX)
      case "${FAMILY}" in
        DEBIAN)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo apt-get -y remove python3
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo apt-get -y install python3
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo apt-get -y --only-upgrade install python3
          fi
          ;;
        RHEL)
          if [ "${COMMAND}" == "remove" ]; then
            ++ sudo dnf -y remove python3
          elif [ "${COMMAND}" == "install" ]; then
            ++ sudo dnf -y install python3
          elif [ "${COMMAND}" == "update" ]; then
            ++ sudo dnf -y update python3
          fi
          ;;
      esac
      ;;
  esac
}

update_asdf_global_py_version() {
  local VERSION="$1"

  if asdf current python >/dev/null 2>&1; then
    local _PY3_VERSION=
    local _PY2_VERSION=

    for i in $(asdf current python | awk '{for (i=2; i<NF; i++) printf "%s ", $i}'); do
      if [[ $i == 3* ]]; then
        _PY3_VERSION=$i
      elif [[ $i == 2* ]]; then
        _PY2_VERSION=$i
      fi
    done

    if [[ $VERSION == 3* ]]; then
      _PY3_VERSION=$VERSION
    elif [[ $VERSION == 2* ]]; then
      _PY2_VERSION=$VERSION
    fi

    ++ asdf global python "$_PY3_VERSION" "$_PY2_VERSION"
  else
    ++ asdf global python "${VERSION}"
  fi
}

# python2_install() {
#   local COMMAND="${1:-skip}"
#   local VERSION="${2:-}"
#   [ -z "${VERSION}" ] && VERSION=$DEFAULT_VERSION
#   VERSION="latest"
#
#   # prefer pyenv
#   if command -v pyenv > /dev/null; then
#     if [ -z ${VERSION} ]; then
#       log_info "List of version"
#       pyenv install --list | grep '^2' | grep -v 'dev'
#       VERSION=$(question "Choose python2 version to install", ${DEFAULT_VERSION})
#     fi
#     if [ ${VERSION} == "latest" ]; then
#       pyenv latest install -s 2
#     else
#       pyenv install ${VERSION}
#     fi
#   elif command -v asdf > /dev/null; then
#
#     if [ "${VERSION}" == "latest" ]; then
#       VERSION=$(asdf latest python 2)
#     fi
#
#     if [ "${COMMAND}" == "remove" ]; then
#       asdf uninstall python "${VERSION}"
#     elif [ "${COMMAND}" == "install" ]; then
#       asdf install python "${VERSION}"
#     elif [ "${COMMAND}" == "update" ]; then
#       log_error "Not supported command 'update'"
#       exit 1
#     fi
#
#     update_asdf_global_py_version "${VERSION}"
#   fi
# }
#
# python3_install() {
#   local COMMAND="${1:-skip}"
#   local VERSION="${2:-}"
#   [ -z "${VERSION}" ] && VERSION=$DEFAULT_VERSION
#
#   # prefer pyenv
#   if command -v pyenv > /dev/null; then
#     if [ -z ${VERSION} ]; then
#       log_info "List of version"
#       pyenv install --list | grep '^3' | grep -v 'dev'
#       VERSION=$(question "Choose python3 version to install", ${DEFAULT_VERSION})
#     fi
#     if [ ${VERSION} == "latest" ]; then
#       pyenv latest install -s 3
#     else
#       pyenv install ${VERSION}
#     fi
#   elif command -v asdf > /dev/null; then
#     if [ "${VERSION}" == "latest" ]; then
#       VERSION=$(asdf latest python 3)
#     fi
#
#     if [ "${COMMAND}" == "remove" ]; then
#       asdf uninstall python "${VERSION}"
#     elif [ "${COMMAND}" == "install" ]; then
#       asdf install python "${VERSION}"
#     elif [ "${COMMAND}" == "update" ]; then
#       log_error "Not supported command 'update'"
#       exit 1
#     fi
#
#     update_asdf_global_py_version "${VERSION}"
#   fi
# }


from_pyenv() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  
  if [ "${COMMAND}" == "remove" ]; then
    ++ pyenv uninstall "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    if [ "${VERSION}" == "latest" ]; then
      ++ pyenv latest install -s 3
    else
      ++ pyenv install "${VERSION}"
    fi
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi

  pyenv global | grep '[0-9.]' -q || pyenv global \
    "$(pyenv versions | sed 's/[[:space:]]//g' | grep '^3' | sort -V -r | head -n 1)" \
    "$(pyenv versions | sed 's/[[:space:]]//g' | grep '^2' | sort -V -r | head -n 1)"
}

from_asdf() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=latest

  asdf plugin list 2>/dev/null | grep -q python || asdf plugin add python >&3 2>&4

  if [ "${VERSION}" == "latest" ]; then
    VERSION=$(asdf latest python 3)
  fi

  if [ "${COMMAND}" == "remove" ]; then
    ++ asdf uninstall python "${VERSION}"
  elif [ "${COMMAND}" == "install" ]; then
    ++ asdf install python "${VERSION}"
  elif [ "${COMMAND}" == "update" ]; then
    log_error "Not supported command 'update'"
    exit 0
  fi

  update_asdf_global_py_version "${VERSION}"
}

python_install() {
  local COMMAND="${1:-skip}"
  local VERSION="${2:-}"
  [ -z "${VERSION}" ] && VERSION=latest

  # prefer pyenv
  if command -v pyenv > /dev/null; then
    if [ "${COMMAND}" == "remove" ]; then
      ++ pyenv uninstall "${VERSION}"
    elif [ "${COMMAND}" == "install" ]; then
      if [ ${VERSION} == "latest" ]; then
        ++ pyenv latest install -s 3
      else
        ++ pyenv install "${VERSION}"
      fi
    elif [ "${COMMAND}" == "update" ]; then
      log_error "Not supported command 'update'"
      exit 0
    fi

  elif command -v asdf > /dev/null; then
    if [ "${VERSION}" == "latest" ]; then
      VERSION=$(asdf latest python 3)
    fi

    if [ "${COMMAND}" == "remove" ]; then
      ++ asdf uninstall python "${VERSION}"
    elif [ "${COMMAND}" == "install" ]; then
      ++ asdf install python "${VERSION}"
    elif [ "${COMMAND}" == "update" ]; then
      log_error "Not supported command 'update'"
      exit 0
    fi

    update_asdf_global_py_version "${VERSION}"
  fi
}

main_script "${THIS}" \
  setup_for_local setup_for_system \
  list_versions verify_version version_func

# upgrade pip
command -v python2 >/dev/null && python2 -m pip install --upgrade pip >&3 2>&4 || true
command -v python3 >/dev/null && python3 -m pip install --upgrade pip >&3 2>&4 || true
