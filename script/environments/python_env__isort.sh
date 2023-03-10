#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
THIS_CMD=isort

log_title "Prepare for ${THIS_HL}"

# python virtualenv path
WORKON_HOME=${HOME}/.virtualenvs
mkdir -p "${WORKON_HOME}" || true

VENV_NAME=${VENV_NAME:-dev-env}
################################################################

version_func() {
  $1 --version | tail -n 2 | awk '{print $2}'
}

setup_for_local() {
  local COMMAND="${1:-skip}"

  if has -v pip3 python3; then
    if [ ! -z ${VENV_NAME+x} ] && [ ! -d "${WORKON_HOME}/${VENV_NAME}" ]; then
      PATH=$(python3 -c "import site; print(site.USER_BASE)")/bin:$PATH
      no_virtualenv=false
      if ! has virtualenv; then
        no_virtualenv=true
        ++ intelli_pip3 install --force-reinstall --upgrade virtualenv
      fi
      ++ virtualenv --python=$(type python3 | awk '{print $3}') "${WORKON_HOME}/${VENV_NAME}"
      if [ $no_virtualenv == true ]; then
          ++ intelli_pip3 uninstall --yes virtualenv
      fi
    fi

    [ ! -z ${VENV_NAME+x} ] && ++ source "${WORKON_HOME}/${VENV_NAME}/bin/activate"
    if [ "${COMMAND}" == "install" ]; then
      ++ intelli_pip3 install isort
    elif [ "${COMMAND}" == "update" ]; then
      ++ intelli_pip3 install isort --force-reinstall --upgrade
    elif [ "${COMMAND}" == "remove" ]; then
      ++ intelli_pip3 uninstall isort
    fi
    [ ! -z ${VENV_NAME+x} ] && ++ deactivate
  else
    log_error "python3 is not found."
    exit 1
  fi
}

main_script "${THIS}" \
  setup_for_local "" \
  "" "" version_func
