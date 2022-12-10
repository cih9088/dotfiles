#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}
TARGET=neovim-providers

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"

# python virtualenv path
export WORKON_HOME=${HOME}/.virtualenvs
mkdir -p "${WORKON_HOME}" || true

NEOVIM3_VIRENV_NAME='neovim3'
################################################################

setup_func_python_provider() {
  local COMMAND="${1:-skip}"

  if has -v pip3 python3; then
    if [[ "remove update"  == *"${COMMAND}"* ]]; then
      rm -rf "${WORKON_HOME}/${NEOVIM3_VIRENV_NAME}" || true
    fi

    if [[ "install update"  == *"${COMMAND}"* ]]; then
      if [ ! -d "${WORKON_HOME}/${NEOVIM3_VIRENV_NAME}" ]; then
        PATH=$(python3 -c "import site; print(site.USER_BASE)")/bin:$PATH
        no_virtualenv=false
        if ! has virtualenv; then
          no_virtualenv=true
          ++ intelli_pip3 install --force-reinstall --upgrade virtualenv
        fi

        ++ virtualenv --python=$(type python3 | awk '{print $3}') "${WORKON_HOME}/${NEOVIM3_VIRENV_NAME}"
        ++ source "${WORKON_HOME}/${NEOVIM3_VIRENV_NAME}/bin/activate"
        ++ pip install --upgrade pynvim
        ++ deactivate

        if [ $no_virtualenv == true ]; then
          ++ intelli_pip3 uninstall --yes virtualenv
        fi
      fi
    fi
  fi
}

setup_func_nodejs_provider() {
  local COMMAND="${1:-skip}"

  if has -v npm; then
    if [ "${COMMAND}" == "remove" ]; then
      ++ npm uninstall --global neovim
    elif [ "${COMMAND}" == "install" ]; then
      ++ npm install --global neovim
    elif [ "${COMMAND}" == "update" ]; then
      ++ npm update --global neovim
    fi
    has asdf && asdf reshim
  fi
}

main_script "neovim-python-provider" setup_func_python_provider "" "" "NONE"
echo ""
main_script "neovim-nodejs-provider" setup_func_nodejs_provider "" "" "NONE"
