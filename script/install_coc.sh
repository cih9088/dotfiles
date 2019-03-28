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

if ! command -v node > /dev/null; then
    exit 1
fi

if ! command -v yarn > /dev/null; then
    exit 1
fi

DIR=~/.local/share/nvim/plugged
# For vim user, the directory is different
# DIR=~/.vim/pack/coc/start
mkdir -p $DIR
cd $DIR
git clone https://github.com/neoclide/coc.nvim.git --depth=1
cd $DIR/coc.nvim
yarn install

# Install extensions
mkdir -p ~/.config/coc/extensions
cd ~/.config/coc/extensions
if [ ! -f package.json ]
then
  echo '{"dependencies":{}}'> package.json
fi

# Change arguments to extensions you need
[[ ":$PATH:" != *":$HOME/.yarn/bin:"* ]] && export PATH="$HOME/.yarn/bin:${PATH}"
[[ ":$PATH:" != *":$HOME/.config/yarn/global/node_modules/.bin:"* ]] && \
    export PATH="$HOME/.config/yarn/global/node_modules/.bin:${PATH}"
yarn add coc-json coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-snippets coc-python

) >&3 2>&4 || exit_code="$?" && true
stop_spinner "${exit_code}" \
    "coc is installed [local]" \
    "coc install is failed [local]. use VERBOSE=YES for error message"

# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
