#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing coc..."
(

[[ ":$PATH:" != *":$HOME/.yarn/bin:"* ]] && export PATH="$HOME/.yarn/bin:${PATH}"
[[ ":$PATH:" != *":$HOME/.config/yarn/global/node_modules/.bin:"* ]] && \
    export PATH="$HOME/.config/yarn/global/node_modules/.bin:${PATH}"

DIR=~/.local/share/nvim/plugged
if [ ! -d ${DIR}/coc.nvim ]; then
    # For vim user, the directory is different
    # DIR=~/.vim/pack/coc/start
    mkdir -p $DIR
    cd $DIR
    git clone https://github.com/neoclide/coc.nvim.git --depth=1
    cd $DIR/coc.nvim
    yarn install
fi

# Install extensions
if [ ! -d '~/.config/coc/extensions' ]; then
    mkdir -p ~/.config/coc/extensions
    cd ~/.config/coc/extensions
    if [ ! -f package.json ]
    then
      echo '{"dependencies":{}}'> package.json
    fi
fi

# Change arguments to extensions you need
yarn add coc-json coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-snippets coc-python coc-go

if [[ -f ${PROJ_HOME}/nvim/coc-settings.json ]]; then
    rm -rf ${PROJ_HOME}/nvim/coc-settings.json.bak || true
    rm -rf ${TMP_DIR}/coc-settings-base.json.trim || true
    cp ${PROJ_HOME}/nvim/coc-settings.json ${PROJ_HOME}/nvim/coc-settings.json.bak
    sed -e '/^{$/d' -e '/^}$/d' -e '/^    }$/d' -e '/languageserver/d' ${PROJ_HOME}/nvim/coc-settings-base.json >> ${TMP_DIR}/coc-settings-base.json.trim
    sed -i -e "/^{$/,/languageserver/{ /^{$/{p; r ${TMP_DIR}/coc-settings-base.json.trim
    }; /languageserver/p; d; /languageserver/d;}" ${PROJ_HOME}/nvim/coc-settings.json
    rm -rf ${TMP_DIR}coc-settings-base.json.trim || true
else
    cp ${PROJ_HOME}/nvim/coc-settings-base.json ${PROJ_HOME}/nvim/coc-settings.json
fi

) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "coc is installed [local]" \
    "coc install is failed [local]. use VERBOSE=YES for error message"

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
