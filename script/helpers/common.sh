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

  DOTS_YES="true"

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

if [ ! -z "${DOTS_TARGET+x}" ]; then
  if [ ! -z "${DOTS_COMMAND+x}" ]; then
    if [[ " "${DOTS_TARGET}" " != *" ${TARGET} "* ]] && [ "${DOTS_COMMAND}" != "install" ]; then
      exit 0
    fi
  fi
  # if [ ! -z "${DOTS_MODE+x}" ]; then
  #   if [[ " "${DOTS_TARGET}" " != *" ${TARGET} "* ]] && [ "${DOTS_MODE}" != "local" ]; then
  #     exit 0
  #   fi
  # fi
  if [ ! -z "${DOTS_SKIP_DEPENDENCIES+x}" ] && [ "$DOTS_SKIP_DEPENDENCIES" == "true" ]; then
    if [[ " "${DOTS_TARGET}" " != *" ${TARGET} "* ]]; then
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
export PATH="$PYENV_ROOT/bin${PATH+:$PATH}"
command -v pyenv > /dev/null && eval "$(pyenv init -)" || true
# goenv
export GOENV_ROOT=$HOME/.goenv
export PATH="$GOENV_ROOT/bin${PATH+:$PATH}"
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
  local _FUNC_LIST_VERSIONS="${4:-}"
  local _FUNC_VERIFY_VERSION="${5:-}"
  local _FUNC_VERSION="${6:-}"
  local _AVAILABLE_VERSIONS=""

  local _TARGET_HL="${BOLD}${UNDERLINE}${_TARGET}${NC}"
  local _TARGET_CMD="${THIS_CMD:-${_TARGET}}"
  local _TARGET_COMMAND=
  local _TARGET_MODE=
  local _TARGET_VERSION=
  local _TARGET_YES=
  local _FUNC_SETUP=
  local _BANNER=

  _TARGET_COMMAND="${DOTS_COMMAND:-}"
  _TARGET_MODE="${DOTS_MODE:-}"
  _TARGET_VERSION="${DOTS_VERSION:-latest}"
  _TARGET_YES="${DOTS_YES:-}"

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
            log_error "Invalid version ${_TARGET_VERSION}"; continue;
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

  # if [[ " ${DOTS_TARGET} " != *" ${_TARGET} "* ]] && [ "${_TARGET_COMMAND}" != "install" ]; then
  #   log_info "Skipped"
  #   return
  # elif [[ " ${DOTS_TARGET} " != *" ${_TARGET} "* ]] && [ "${_TARGET_MODE}" == "system" ]; then
  #   log_info "Skipped"
  #   return
  # fi

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
      _BANNER="[mode=system]"
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
      if [[ "${_TARGET_MODE}" == "system" && "${PLATFORM}" == "LINUX" && "${FAMILY}" == "DEBIAN" ]]; then
        ++ sudo apt-get update
        # sudo drops user environment
        # [ "${VERBOSE}" = "false" ] && DEBIAN_FRONTEND=noninteractive
        sudo() {
          local _sudo="$(type -ap sudo | head -n1)"
          "$_sudo" "DEBIAN_FRONTEND=noninteractive" "$@"
        }
      fi
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
