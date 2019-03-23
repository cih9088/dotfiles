#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

# dotnet
if [[ $platform == OSX ]]; then
   brew cask install dotnet-sdk
else
   rm -rf ${HOME}/.dotnet || true
   rm -rf ${HOME}/.local/bin/dotnet || true
   wget https://dot.net/v1/dotnet-install.sh -P ${TMP_DIR}
   chmod +x ${TMP_DIR}/dotnet-install.sh
   ${TMP_DIR}/dotnet-install.sh -c 2.2
   ln -snf ${HOME}/.dotnet/dotnet ${HOME}/.local/bin/dotnet
fi

# mspyls
rm -rf ${HOME}/.mpls || true
mkdir -p ${HOME}/.mpls

MPLS_VERSION="$(./get_latest_release 'Microsoft/python-language-server')"
wget https://github.com/Microsoft/python-language-server/archive/${MPLS_VERSION}.tar.gz -P ${HOME}/.mpls
(
cd ${HOME}/.mpls
tar -xvzf ${MPLS_VERSION}.tar.gz --strip-components=1
cd ${HOME}/.mpls/src/LanguageServer/Impl
${HOME}/.local/bin/dotnet build --configuration Release
)

# git clone https://github.com/Microsoft/python-language-server.git ${HOME}/.mpls
# (
# cd ${HOME}/.mpls/src/LanguageServer/Impl
# ${HOME}/.local/bin/dotnet build --configuration Release
# )

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
yarn add coc-json coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-snippets
