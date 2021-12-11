#!/usr/bin/env bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/colours.sh
. ${DIR}/functions.sh
. ${DIR}/platform.sh
. ${DIR}/spinner/spinner.sh
################################################################

PROJ_HOME=${PROJ_HOME:-$(git rev-parse --show-toplevel)}
BIN_DIR=${BIN_DIR:=${PROJ_HOME}/bin}
SCRIPTS_DIR=${SCRIPTS_DIR:=${PROJ_HOME}/script}

VERBOSE=$(echo ${VERBOSE:-false} | tr '[:upper:]' '[:lower:]')

PREFIX=${PREFIX:-$HOME/.local}
mkdir -p ${HOME}/.config
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/src
mkdir -p ${PREFIX}/lib/pkgconfig

# path
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
export PATH="${PREFIX}/bin${PATH+:$PATH}"

# build path
export LD_LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib64${LD_LIBRARY_PATH+:$LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig${PKG_CONFIG_PATH+:$PKG_CONFIG_PATH}"
export CFLAGS="-I${PREFIX}/include"
export CPPFLAGS="-I${PREFIX}/include"
export CXXFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/lib64"
################################################################

# asdf
if [ -f $HOME/.asdf/asdf.sh ]; then
  export ASDF_DIR=${HOME}/.asdf
  . ${ASDF_DIR}/asdf.sh
elif command -v brew >/dev/null && [ -f $(brew --prefix asdf)/libexec/asdf.sh ]; then
  export ASDF_DIR=$(brew --prefix asdf)/libexec
  . ${ASDF_DIR}/asdf.sh
fi
# pyenv
export PYENV_ROOT=$HOME/.pyenv
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true
# goenv
export GOENV_ROOT=$HOME/.goenv
command -v goenv > /dev/null && eval "$(goenv init -)" || true

################################################################

# parse config
[[ ! -z ${CONFIG+x} ]] && eval $(${PROJ_HOME}/script/helpers/parser_yaml ${CONFIG} "CONFIG_") || true
# set verbose
[[ "${VERBOSE}" == "true" ]] && exec 3>&1 4>&2 || exec 3>/dev/null 4>/dev/null
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
  local _TARGET_INSTALL=false
  local _TARGET_LOCAL=true
  local _TARGET_FORCE=false
  local _TARGET_VERSION=
  local _FUNC_SETUP=
  local _BANNER=

  # if _FUNC_VERSION is given, process version checker
  if [ ! -z ${_FUNC_VERSION} ]; then
    if [ -x "$(command -v ${_TARGET_CMD})" ]; then
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

  if [[ ! -z ${CONFIG+x} ]]; then
    # config is given
    _TARGET_INSTALL="CONFIG_${_TARGET}_install"
    _TARGET_LOCAL="CONFIG_${_TARGET}_local"
    _TARGET_FORCE="CONFIG_${_TARGET}_force"
    _TARGET_VERSION="CONFIG_${_TARGET}_version"
    _TARGET_INSTALL=${!_TARGET_INSTALL:-false}
    _TARGET_LOCAL=${!_TARGET_LOCAL:-true}
    _TARGET_FORCE=${!_TARGET_FORCE:-false}
    _TARGET_VERSION=${!_TARGET_VERSION:-${_DEFAULT_VERSION}}
  else
    # interactively
    while true; do
      yn=$(log_question "Do you want to install ${_TARGET_HL}? [y/n]")
      case $yn in
        [Yy]* ) _TARGET_INSTALL="true"; ;;
        [Nn]* ) log_info "Aborting install ${_TARGET_HL}."; break;;
        * ) log_error "Please answer 'yes' or 'no'."; continue;;
      esac

      yn=$(log_question "Do you wish to update ${_TARGET_HL} if it was already installed? [y/n]")
      case $yn in
        [Yy]* ) _TARGET_FORCE=true; ;;
        [Nn]* ) _TARGET_FORCE=false; ;;
        * ) log_error "Please answer 'yes' or 'no'."; continue;;
      esac

      if [ "${_FUNC_SETUP_LOCAL}" != "${_FUNC_SETUP_SYSTEM}" ]; then
        yn=$(question "Install locally or systemwide?")
        case $yn in
          [Ll]ocal* )
            _TARGET_LOCAL=true
            ;;
          [Ss]ystem* )
            _TARGET_LOCAL=false
            ;;
          * ) log_error "Please answer 'locally' or 'systemwide'."; continue;;
        esac
      fi

      if [ $_TARGET_LOCAL == "true" ]; then
        if [ ! -z "${_DEFAULT_VERSION}" ]; then
          _TARGET_VERSION=${_DEFAULT_VERSION}
          if [ ! -z "${_AVAILABLE_VERSIONS}" ]; then
            log_info "List of available versions"
            echo "${_AVAILABLE_VERSIONS}"
          fi
          if [ ! -z "${_FUNC_VERIFY_VERSION}" ]; then
            _TARGET_VERSION=$(question "Which version to install?" ${_DEFAULT_VERSION})
            if ! ${_FUNC_VERIFY_VERSION} ${_TARGET_VERSION}; then
              log_error "Invalid version ${_TARGET_VERSION}"; continue;
            fi
          fi
        fi
      fi

      break
    done
  fi

  if [ ${_TARGET_INSTALL} == "true" ]; then
    local _TMP_DIR=$(mktemp -d -t dotfiles.andy.XXXXX)

    if [ $_TARGET_LOCAL == "true" ]; then
      _FUNC_SETUP="${_FUNC_SETUP_LOCAL}"
      _BANNER="[mode=local, force=${_TARGET_FORCE}, version=${_TARGET_VERSION}]"
    else
      _FUNC_SETUP="${_FUNC_SETUP_SYSTEM}"
      _BANNER="[mode=systrm, force=${_TARGET_FORCE}]"
    fi

    [[ ${VERBOSE} == "true" ]] &&
      log_info "Installing ${_TARGET_HL}... ${_BANNER}" ||
      start_spinner "Installing ${_TARGET_HL}... ${_BANNER}"
    (
      cd ${_TMP_DIR}
      ${_FUNC_SETUP} ${_TARGET_FORCE} ${_TARGET_VERSION}
    ) >&3 2>&4 && exit_code="0" || exit_code="$?"
    stop_spinner "${exit_code}" \
      "${_TARGET_HL} is installed ${_BANNER}" \
      "${_TARGET_HL} install is failed ${_BANNER}. Add 'VERBOSE=true' for debugging."

    # clean up
    rm -rf ${_TMP_DIR}
  else
    log_ok "${_TARGET_HL} is not installed"
  fi
}
