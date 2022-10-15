#!/usr/bin/env bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/colours.sh
. ${DIR}/functions.sh
. ${DIR}/platform.sh
. ${DIR}/spinner/spinner.sh
################################################################
TARGET=${TARGET:-$(basename -- ${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]})}
TARGET=$(echo "${TARGET%.*}" | sed -e 's/_/-/g')

if [ ! -z "${CONFIG+x}" ] && [ -n "${CONFIG}" ]; then
  # config is given
  eval $(${PROJ_HOME}/script/helpers/parser_yaml ${CONFIG} "CONFIG_")

  DOTFILES_YES="true"

  # underscore to dash
  _TARGET=${TARGET/-/_}

  _TARGET_MODE_CONFIG="CONFIG_${_TARGET}_mode"
  if [ ! -z "${!_TARGET_MODE_CONFIG+x}" ]; then
    DOTFILES_MODE=${!_TARGET_MODE_CONFIG}
  fi

  _TARGET_VERSION_CONFIG="CONFIG_${_TARGET}_version"
  if [ ! -z "${!_TARGET_VERSION_CONFIG+x}" ]; then
    DOTFILES_VERSION=${!_TARGET_VERSION_CONFIG}
  fi
fi

if [ ! -z "${DOTFILES_TARGET+x}" ]; then
  if [ ! -z "${DOTFILES_COMMAND+x}" ]; then
    if [[ " "${DOTFILES_TARGET}" " != *" ${TARGET} "* ]] && [ "${DOTFILES_COMMAND}" != "install" ]; then
      exit 0
    fi
  fi
  # if [ ! -z "${DOTFILES_MODE+x}" ]; then
  #   if [[ " "${DOTFILES_TARGET}" " != *" ${TARGET} "* ]] && [ "${DOTFILES_MODE}" != "local" ]; then
  #     exit 0
  #   fi
  # fi
  if [ ! -z "${DOTFILES_SKIP_DEPENDENCIES+x}" ] && [ "$DOTFILES_SKIP_DEPENDENCIES" == "true" ]; then
    if [[ " "${DOTFILES_TARGET}" " != *" ${TARGET} "* ]]; then
      exit 0
    fi
  fi
fi
################################################################

PROJ_HOME=${PROJ_HOME:-$(git rev-parse --show-toplevel)}
BIN_DIR=${BIN_DIR:=${PROJ_HOME}/bin}
SCRIPTS_DIR=${SCRIPTS_DIR:=${PROJ_HOME}/script}

VERBOSE=$(echo "${VERBOSE:-false}" | tr '[:upper:]' '[:lower:]')

PREFIX=${PREFIX:-$HOME/.local}
mkdir -p "${HOME}/.config"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/src"
mkdir -p "${PREFIX}/lib/pkgconfig"
mkdir -p "${PREFIX}/lib64/pkgconfig"
mkdir -p "${PREFIX}/include"
mkdir -p "${PREFIX}/share"
mkdir -p "${PREFIX}/share/man/man1"
mkdir -p "${PREFIX}/share/bash-completion/completions"

# path
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
export PATH="${PREFIX}/bin${PATH+:$PATH}"

# build path
export LD_LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib64${LD_LIBRARY_PATH+:$LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig${PKG_CONFIG_PATH+:$PKG_CONFIG_PATH}"
export ACLOCAL_PATH="${PREFIX}/share/aclocal${ACLOCAL_PATH+:$ACLOCAL_PATH}"
export CFLAGS="-I${PREFIX}/include"
export CPPFLAGS="-I${PREFIX}/include"
export CXXFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/lib64"
################################################################

# asdf
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  export ASDF_DIR=${HOME}/.asdf
  . "${ASDF_DIR}/asdf.sh"
elif command -v brew >/dev/null && [ -f $(brew --prefix asdf)/libexec/asdf.sh ]; then
  export ASDF_DIR=$(brew --prefix asdf)/libexec
  . "${ASDF_DIR}/asdf.sh"
fi
# pyenv
export PYENV_ROOT=$HOME/.pyenv
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true
# goenv
export GOENV_ROOT=$HOME/.goenv
command -v goenv > /dev/null && eval "$(goenv init -)" || true
# build python with shared object
# (https://github.com/pyenv/pyenv/tree/master/plugins/python-build#building-with---enable-shared)
export PYTHON_CONFIGURE_OPTS="--enable-shared"

################################################################

# set verbose
# 3: stdout, 4: stderr, 5: logger
[[ "${VERBOSE}" == "true" ]] && exec 3>&1 4>&2 5>&2 || exec 3>/dev/null 4>/dev/null 5>&2
# check platform and family
if [[ ${PLATFORM} != OSX && ${PLATFORM} != LINUX ]]; then
  log_error "${PLATFORM} is not supported."
  exit 1
fi
if [[ "${PLATFORM}" == "LINUX" && -z "${FAMILY}" ]]; then
  log_error "linux family '${FAMILY}' is not supported."
  exit 1;
fi

################################################################


question() {
  # usage
  # value=$(question "question" ["default"])

  local question="$1"
  local default="${2:-}"
  local answer

  while true; do
    [ ! -z "${default}" ] && question="${question} (default: ${default})"
    answer=$(log_question "${question}")
    answer="$(echo -e "${answer}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [ -z "${answer}" ] && [ ! -z "${default}" ]; then
      log_info "You left empty. The default value '${default}' is used."
      answer="${default}"
    else
      log_info "You typed '${answer}'."
    fi

    yn=$(log_question "Is it correct? [y/n]")
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) continue;;
      * ) log_error "Please answer 'yes' or 'no'." ; continue;;
    esac
  done

  echo "${answer}"
}

main_script() {
  local _TARGET="$1"
  local _FUNC_SETUP_LOCAL="$2"
  local _FUNC_SETUP_SYSTEM="$3"
  local _FUNC_VERSION="${4:-}"
  local _DEFAULT_VERSION="${5:-}"
  local _AVAILABLE_VERSIONS="${6:-}"
  local _FUNC_VERIFY_VERSION="${7:-}"

  local _TARGET_HL="${BOLD}${UNDERLINE}${_TARGET}${NC}"
  local _TARGET_CMD="${THIS_CMD:-${_TARGET}}"
  local _TARGET_COMMAND=
  local _TARGET_MODE=
  local _TARGET_VERSION=
  local _TARGET_YES=
  local _FUNC_SETUP=
  local _BANNER=

  _TARGET_COMMAND="${DOTFILES_COMMAND:-}"
  _TARGET_MODE="${DOTFILES_MODE:-}"
  _TARGET_VERSION="${DOTFILES_VERSION:-${_DEFAULT_VERSION}}"
  _TARGET_YES="${DOTFILES_YES:-}"

  # # underscore to dash
  # _TARGET=${_TARGET/_/-}

  # if _FUNC_VERSION is given, process version checker
  if [ -n "${_FUNC_VERSION}" ]; then
    if [ -x "$(command -v "${_TARGET_CMD}")" ]; then
      log_info "The Following list is ${_TARGET_HL} installed on the machine."
      coms=($(type -a ${_TARGET_CMD} | awk '{print $3}' | uniq))
      (
        printf 'LOCATION,VERSION\n'
        for com in "${coms[@]}"; do
          printf '%s,%s\n' "${com}" "$( ${_FUNC_VERSION} ${com} )"
        done
      ) | column -t -s ',' | sed 's/^/    /'
    else
      log_info "${_TARGET_HL} is not found on the machine."
    fi
  fi

  # interactively
  while true; do
    if [ -z "${_TARGET_COMMAND}" ]; then
      yn=$(log_question "Do you want to install or remove ${_TARGET_HL}? [install/update/remove/skip]")
      case $yn in
        [Ii]nstall* ) _TARGET_COMMAND="install"; ;;
        [Uu]pdate* ) _TARGET_COMMAND="update"; ;;
        [Rr]emove* ) _TARGET_COMMAND="remove"; ;;
        [Ss]kip* ) _TARGET_COMMAND="skip"; ;;
        * ) log_error "Please answer 'install' 'update' or 'remove' or 'skip'."; continue;;
      esac
    fi

    if [ "${_TARGET_COMMAND}" == "skip" ]; then
      return
    fi

    if [ -z "${_TARGET_MODE}" ]; then
      if [ "${_FUNC_SETUP_LOCAL}" != "${_FUNC_SETUP_SYSTEM}" ]; then
        yn=$(question "$(tr '[:lower:]' '[:upper:]' <<< ${_TARGET_COMMAND:0:1})${_TARGET_COMMAND:1} locally or systemwide?")
        case $yn in
          [Ll]ocal* ) _TARGET_MODE=local; ;;
          [Ss]ystem* ) _TARGET_MODE=system; ;;
          * ) log_error "Please answer 'locally' or 'systemwide'."; continue;;
        esac
      else
        _TARGET_MODE="local"
      fi
    fi

    if [ -z "${_TARGET_YES}" ] && [[ "install update" ==  *"$_TARGET_COMMAND"* ]]; then
      if [ $_TARGET_MODE == "local" ]; then
        if [ -n "${_DEFAULT_VERSION}" ]; then
          _TARGET_VERSION=${_DEFAULT_VERSION}
          if [ -n "${_AVAILABLE_VERSIONS}" ]; then
            log_info "List of available versions"
            echo "${_AVAILABLE_VERSIONS}"
          fi
          if [ -n "${_FUNC_VERIFY_VERSION}" ]; then
            _TARGET_VERSION=$(question "Which version to install?" ${_DEFAULT_VERSION})
            if ! ${_FUNC_VERIFY_VERSION} ${_TARGET_VERSION}; then
              log_error "Invalid version ${_TARGET_VERSION}"; continue;
            fi
          fi
        fi
      fi
    fi

    if [ -z "${_TARGET_YES}" ]; then
      yn=$(log_question "Do you want to ${_TARGET_COMMAND} ${_TARGET_HL}?  [y/n]")
      case $yn in
        [Yy]* ) _TARGET_YES="true"; ;;
        [Nn]* ) log_info "Aborting install ${_TARGET_HL}."; _TARGET_YES="false"; break;;
        * ) log_error "Please answer 'yes' or 'no'."; continue;;
      esac
    fi
    break
  done

  # if [[ " ${DOTFILES_TARGET} " != *" ${_TARGET} "* ]] && [ "${_TARGET_COMMAND}" != "install" ]; then
  #   log_info "Skipped"
  #   return
  # elif [[ " ${DOTFILES_TARGET} " != *" ${_TARGET} "* ]] && [ "${_TARGET_MODE}" == "system" ]; then
  #   log_info "Skipped"
  #   return
  # fi

  if [ ${_TARGET_YES} == "true" ]; then
    local _TMP_DIR=$(mktemp -d -t dotfiles.XXXXXXXX)

    if [ "${_TARGET_MODE}" == "local" ]; then
      _FUNC_SETUP="${_FUNC_SETUP_LOCAL}"
      _BANNER="[mode=local, version=${_TARGET_VERSION}]"
    else
      _FUNC_SETUP="${_FUNC_SETUP_SYSTEM}"
      _BANNER="[mode=system]"
    fi

    if [ -z "${_FUNC_SETUP}" ]; then
      log_error "${_TARGET_MODE} is not supported for ${THIS_HL}."
      exit 1
    fi

    if [ "${_TARGET_COMMAND}" = "install" ]; then
      _BEGIN_BANNER="Installing ${_TARGET_HL}... ${_BANNER}"
      _END_BANNER_PASS="${_TARGET_HL} is installed ${_BANNER}"
      _END_BANNER_FAIL="${_TARGET_HL} is failed to install. Please make it verbose for debugging ${_BANNER}"
    elif [ "${_TARGET_COMMAND}" = "update" ]; then
      _BEGIN_BANNER="Updating ${_TARGET_HL}... ${_BANNER}"
      _END_BANNER_PASS="${_TARGET_HL} is updated ${_BANNER}"
      _END_BANNER_FAIL="${_TARGET_HL} is failed to update. Please make it verbose for debugging ${_BANNER}"
    elif [ "${_TARGET_COMMAND}" = "remove" ]; then
      _BEGIN_BANNER="Removing ${_TARGET_HL}... ${_BANNER}"
      _END_BANNER_PASS="${_TARGET_HL} is removed ${_BANNER}"
      _END_BANNER_FAIL="${_TARGET_HL} is failed to remove. Please make it verbose for debugging ${_BANNER}"
    fi

    [ "${VERBOSE}" = "true" ] &&
      log_info "${_BEGIN_BANNER}" ||
      start_spinner "${_BEGIN_BANNER}"
    (
      log_info "Temp directory: ${_TMP_DIR}"
      cd "${_TMP_DIR}"
      "${_FUNC_SETUP}" "${_TARGET_COMMAND}" "${_TARGET_VERSION}"
    ) >&3 2>&4 && exit_code="0" || exit_code="$?"
    stop_spinner "${exit_code}" "$_END_BANNER_PASS" "$_END_BANNER_FAIL"

    if [ "$exit_code" -ne 0 ]; then
      exit "$exit_code"
    fi

    # clean up
    rm -rf "${_TMP_DIR}"
  else
    log_ok "Skipping ${_TARGET_HL}."
  fi
}
