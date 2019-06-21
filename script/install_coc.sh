#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
[[ ${VERBOSE} == YES ]] || start_spinner "Installing coc..."
(

# # dotnet
# if [[ $platform == OSX ]]; then
#    brew cask install dotnet-sdk
# else
#    rm -rf ${HOME}/.dotnet || true
#    rm -rf ${HOME}/.local/bin/dotnet || true
#    wget https://dot.net/v1/dotnet-install.sh -P ${TMP_DIR}
#    chmod +x ${TMP_DIR}/dotnet-install.sh
#    ${TMP_DIR}/dotnet-install.sh -c 2.2
#    ln -snf ${HOME}/.dotnet/dotnet ${HOME}/.local/bin/dotnet
# fi
#
# # mspyls
# rm -rf ${HOME}/.mpls || true
# mkdir -p ${HOME}/.mpls
#
# # MPLS_VERSION="$(${PROJ_HOME}/script/get_latest_release 'Microsoft/python-language-server')"
# # wget https://github.com/Microsoft/python-language-server/archive/${MPLS_VERSION}.tar.gz -P ${HOME}/.mpls
# # (
# # cd ${HOME}/.mpls
# # tar -xvzf ${MPLS_VERSION}.tar.gz --strip-components=1
# # cd ${HOME}/.mpls/src/LanguageServer/Impl
# # ${HOME}/.local/bin/dotnet build --configuration Release
# # )
#
# git clone https://github.com/Microsoft/python-language-server.git ${HOME}/.mpls
# (
# cd ${HOME}/.mpls/src/LanguageServer/Impl
# ${HOME}/.local/bin/dotnet build --configuration Debug
# )

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
yarn add coc-json coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-snippets coc-python

if [[ -f ${PROJ_HOME}/nvim/coc-settings.json ]]; then
    cp ${PROJ_HOME}/nvim/coc-settings.json ${PROJ_HOME}/nvim/coc-settings.json.bak
    rm -rf ${TMP_DIR}/coc-settings-base.json.trim || true
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
