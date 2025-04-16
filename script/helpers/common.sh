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
DEPTH_SEP="--"

if [ ! -z "${CONFIG+x}" ] && [ -n "${CONFIG}" ]; then
  # config is given
  eval $(${PROJ_HOME}/script/helpers/parser_yaml ${CONFIG} "CONFIG_")

  _TARGET=${TARGET}
  _TARGET=(${_TARGET//${DEPTH_SEP}/ })
  for i in $(seq $((${#_TARGET[@]}-1)) -1 0); do
    __TARGET=""
    for j in $(seq 0 "$i"); do
      __TARGET="${__TARGET}${DEPTH_SEP}${_TARGET[j]}"
    done
    __TARGET=${__TARGET/${DEPTH_SEP}/}${DEPTH_SEP}
    __TARGET=${__TARGET//-/_}

    _TARGET_MODE_CONFIG="CONFIG_${__TARGET}mode"
    if [ ! -z "${!_TARGET_MODE_CONFIG+x}" ]; then
      DOTS_MODE=${!_TARGET_MODE_CONFIG}
    fi

    _TARGET_VERSION_CONFIG="CONFIG_${__TARGET}version"
    if [ ! -z "${!_TARGET_VERSION_CONFIG+x}" ]; then
      DOTS_VERSION=${!_TARGET_VERSION_CONFIG}
    fi
  done
fi


is_target_found() {
  local _TMP_TARGET=$TARGET
  local _FOUND=1

  [ -z "${DOTS_TARGET+x}" ] && return 0

  while [ ! -z "${_TMP_TARGET}" ] && [ $_FOUND = 1 ]; do
    if [[ " "${DOTS_TARGET}" " == *" ${_TMP_TARGET} "* ]]; then
      _FOUND=0
    fi
    _TMP_TARGET=(${_TMP_TARGET//${DEPTH_SEP}/ })
    _TMP_TARGET=${_TMP_TARGET[@]:0:$((${#_TMP_TARGET[@]} - 1))}
  done

  return $_FOUND
}

if ! is_target_found; then
  [ "${DOTS_COMMAND}" = "remove" ] && exit 0
  if [ ! -z "${DOTS_SKIP_DEPENDENCIES+x}" ] && [ "$DOTS_SKIP_DEPENDENCIES" == "true" ]; then
    exit 0
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
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/lib64"

# remove trailing colon (some libs failed to install)
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH%:}
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH%:}
################################################################

# asdf
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  export ASDF_DIR=${HOME}/.asdf
  . "${ASDF_DIR}/asdf.sh"
elif command -v brew >/dev/null && [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
  export ASDF_DIR=$(brew --prefix asdf)/libexec
  . "${ASDF_DIR}/asdf.sh"
fi

# mise
_MISE_BINARY=
if [ -f "${PREFIX}/bin/mise" ]; then
  _MISE_BINARY="${PREFIX}/bin/mise"
elif command -v brew >/dev/null && [ -f "$(brew --prefix mise)/bin/mise" ]; then
  _MISE_BINARY="$(brew --prefix mise)/bin/mise"
fi
if [ ! -z "${_MISE_BINARY+x}" ]; then
  eval "$(${_MISE_BINARY} activate bash)"
  export MISE_VERBOSE=1
  # https://mise.jdx.dev/lang/python.html#python.compile
  # make mise compile python instead of download precompiled version
  export MISE_PYTHON_COMPILE=true
fi
unset _MISE_BINARY

# pyenv
export PYENV_ROOT=$HOME/.pyenv
export PATH="$PYENV_ROOT/bin${PATH+:$PATH}"
command -v pyenv >/dev/null && eval "$(pyenv init -)" || true

# goenv
export GOENV_ROOT=$HOME/.goenv
export PATH="$GOENV_ROOT/bin${PATH+:$PATH}"
command -v goenv >/dev/null && eval "$(goenv init -)" || true

# build python with shared object
# (https://github.com/pyenv/pyenv/tree/master/plugins/python-build#building-with---enable-shared)
export PYTHON_CONFIGURE_OPTS="--enable-shared"


################################################################

# set verbose
# 3: stdout, 4: stderr, 5: logger
[[ "${VERBOSE}" == "true" ]] && exec 3>&1 4>&2 5>&2 || exec 3>/dev/null 4>/dev/null 5>&2
# check platform and linux
if [[ ${PLATFORM} != OSX && ${PLATFORM} != LINUX ]]; then
  log_error "${PLATFORM} is not supported."
  exit 1
fi
if [[ "${PLATFORM}" == "LINUX" && " ubuntu debian centos rocky " != *" ${PLATFORM_ID} "* ]]; then
  log_error "linux '${PLATFORM_ID}' is not supported."
  exit 1
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
  local _FUNC_LIST_VERSIONS="${4:-}"
  local _FUNC_VERIFY_VERSION="${5:-}"
  local _FUNC_VERSION="${6:-}"
  local _AVAILABLE_VERSIONS=""

  local _TARGET_HL="${BOLD}${UNDERLINE}${_TARGET}${NC}"
  local _TARGET_CMD="${THIS_CMD:-${_TARGET}}"
  local _TARGET_COMMAND="${DOTS_COMMAND:-}"
  local _TARGET_MODE="${DOTS_MODE:-}"
  local _TARGET_VERSION=
  local _TARGET_YES=
  local _FUNC_SETUP=
  local _BANNER=

  _TARGET_COMMAND="${DOTS_COMMAND:-}"
  _TARGET_MODE="${DOTS_MODE:-}"
  _TARGET_VERSION="${DOTS_VERSION:-latest}"
  _TARGET_YES="${DOTS_YES:-}"

  if ! is_target_found; then
    _TARGET_VERSION="latest"
  fi

  # debug mode
  if [ "${_TARGET_MODE}" = "debug" ]; then
    if is_target_found; then
      _TARGET_MODE=local
    else
      _TARGET_MODE=system
    fi
  fi

  # if _FUNC_VERSION is given, process version checker
  if [ -n "${_FUNC_VERSION}" ]; then
    if command -v "${_TARGET_CMD}" &> /dev/null; then
      log_info "The Following list is ${_TARGET_HL} installed on the machine."
      coms=($(type -a -p ${_TARGET_CMD} | awk '{print $NF}' | uniq))
      (
        printf 'LOCATION,VERSION\n'
        for com in "${coms[@]}"; do
          printf '%s,%s\n' "${com}" "$( ${_FUNC_VERSION} ${com} )"
        done
      ) | awk -F',' '
        BEGIN { l=0; ctr=0 }
        {
          locations[NR]=$1
          versions[NR]=$2
          ctr+=1
          if (length($1) > l) {
            l=length($1)
          }
        }
        END {
          for (i = 1; i <= ctr; i++) {
            printf "%*s  %s\n", l, locations[i], versions[i]
          }
        }
      '
    else
      log_info "${_TARGET_HL} is not found on the machine."
    fi
  fi

  # interactively
  while true; do
    if [ -z "${_TARGET_COMMAND}" ]; then
      yn=$(log_question "What do you want for ${_TARGET_HL}? [install/update/remove/skip]")
      case $yn in
        [Ii]nstall* ) _TARGET_COMMAND="install"; ;;
        [Uu]pdate* ) _TARGET_COMMAND="update"; ;;
        [Rr]emove* ) _TARGET_COMMAND="remove"; ;;
        [Ss]kip* ) _TARGET_COMMAND="skip"; ;;
        * ) log_error "Please answer 'install' 'update' or 'remove' or 'skip'."; continue;;
      esac
    fi

    if [ "${_TARGET_COMMAND}" == "skip" ]; then
      log_ok "Skipping ${_TARGET_HL}."
      return
    fi

    if [ -z "${_TARGET_MODE}" ]; then
      if [ "${_FUNC_SETUP_LOCAL}" == "" ]; then
        _TARGET_MODE="system"
      elif [ "${_FUNC_SETUP_SYSTEM}" == "" ]; then
        _TARGET_MODE="local"
      else
        yn=$(question "$(tr '[:lower:]' '[:upper:]' <<< ${_TARGET_COMMAND:0:1})${_TARGET_COMMAND:1} locally or systemwide?")
        case $yn in
          [Ll]ocal* ) _TARGET_MODE=local; ;;
          [Ss]ystem* ) _TARGET_MODE=system; ;;
          * ) log_error "Please answer 'locally' or 'systemwide'."; continue;;
        esac
      fi
    fi

    if [ -z "${_TARGET_YES}" ] && [[ "install update" ==  *"$_TARGET_COMMAND"* ]]; then
      if [ "$_TARGET_MODE" == "local" ]; then
        if [ -n "${_FUNC_LIST_VERSIONS}" ] && [ -z "${_AVAILABLE_VERSIONS}" ]; then
          _AVAILABLE_VERSIONS="$(${_FUNC_LIST_VERSIONS})"
        fi

        if [ -n "${_AVAILABLE_VERSIONS}" ]; then
          log_info "List of available versions"
          echo "${_AVAILABLE_VERSIONS}"
          _TARGET_VERSION=$(echo ${_AVAILABLE_VERSIONS} | head -n 1)
        fi
        if [ -n "${_FUNC_VERIFY_VERSION}" ]; then
          _TARGET_VERSION=$(question "Which version to install?" ${_TARGET_VERSION})
          if ! ${_FUNC_VERIFY_VERSION} ${_TARGET_VERSION} "${_AVAILABLE_VERSIONS}"; then
            log_error "Invalid version '${_TARGET_VERSION}'."; continue;
          fi
        fi
      fi
    fi

    if [ -z "${_TARGET_YES}" ]; then
      yn=$(log_question "Do you want to ${_TARGET_COMMAND} ${_TARGET_HL}=${_TARGET_VERSION} in ${_TARGET_MODE} mode?  [y/n]")
      case $yn in
        [Yy]* ) _TARGET_YES="true"; ;;
        [Nn]* ) log_info "Aborting ${_TARGET_COMMAND} ${_TARGET_HL}."; _TARGET_YES="false"; break;;
        * ) log_error "Please answer 'yes' or 'no'."; continue;;
      esac
    fi

    break
  done

  if [ ${_TARGET_YES} == "true" ]; then
    local _TMP_DIR=$(mktemp -d -t dotfiles.XXXXXXXX)

    if [ "${_TARGET_MODE}" == "local" ] && [ -z "${_FUNC_SETUP_LOCAL}" ]; then
      log_info "The mode is changed to 'system' since 'local' is not supported for '${_TARGET}'"
      _TARGET_MODE="system"
    elif [ "${_TARGET_MODE}" == "system" ] && [ -z "${_FUNC_SETUP_SYSTEM}" ]; then
      log_info "The mode is changed to 'local' since 'system' is not supported for '${_TARGET}'"
      _TARGET_MODE="local"
    fi

    if [ "${_TARGET_MODE}" == "local" ]; then
      _FUNC_SETUP="${_FUNC_SETUP_LOCAL}"
      _BANNER="[mode=local, version=${_TARGET_VERSION}]"
    else
      _FUNC_SETUP="${_FUNC_SETUP_SYSTEM}"
      _BANNER="[mode=system, version=${_TARGET_VERSION}]"
      sudo -v
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
      if [[ "${_TARGET_MODE}" == "system" && "${PLATFORM}" == "LINUX" && " ubuntu debian " == *" ${PLATFORM_ID} "* ]]; then
        ++ sudo apt update
        # sudo drops user environment
        # [ "${VERBOSE}" = "false" ] && DEBIAN_FRONTEND=noninteractive
        sudo() {
          local _sudo="$(type -ap sudo | head -n1)"
          "$_sudo" "DEBIAN_FRONTEND=noninteractive" "$@"
        }
      fi
      cd "${_TMP_DIR}"
      "${_FUNC_SETUP}" "${_TARGET_COMMAND}" "${_TARGET_VERSION}"
    ) >&3 2>&4 && exit_code="0" || exit_code="$?"
    stop_spinner "${exit_code}" "$_END_BANNER_PASS" "$_END_BANNER_FAIL"

    if [ "$exit_code" -ne 0 ]; then
      log_info "Temp directory: ${_TMP_DIR}"
      exit "$exit_code"
    fi

    # clean up if it succeeded
    if [ "${_TARGET_COMMAND}" != "install" ]; then
      for file in $(find ${PREFIX} -type l ! -exec test -e {} \; -print); do
        log_info "Remove broken symbolic link '$file'"
        rm -rf ${file}
      done
    fi
    rm -rf "${_TMP_DIR}"
  else
    log_ok "Skipping ${_TARGET_HL}."
  fi
}
