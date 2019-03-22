#!/usr/bin/env bash

# dotnet
if [[ $platform == OSX ]]; then
    brew cask install dotnet-sdk
else [[ $platform == LINUX ]]; then
    wget https://dot.net/v1/dotnet-install.sh ${TMP_DIR}
    chmod +x ${TMP_DIR}/dotnet-install.sh
    ${TMP_DIR}/dotnet-install.sh
    ln -snf ${HOME}/.dotnet/dotnet ${HOME}/.local/bin/dotnet
fi

# mspyls
rm -rf ${HOME}/.mpls || true
mkdir -p ${HOME}/.mpls
git clone https://github.com/Microsoft/python-language-server.git ${HOME}/.mpls
(
cd ${HOME}/.mpls/src/LanguageServer/Impl
dotnet build --configuration Release
)

# Install extensions
mkdir -p ~/.config/coc/extensions
cd ~/.config/coc/extensions
if [ ! -f package.json ]
then
  echo '{"dependencies":{}}'> package.json
fi
# Change arguments to extensions you need
yarn add coc-json coc-tsserver coc-html coc-css coc-emoji coc-yaml coc-vimtex coc-snippets
