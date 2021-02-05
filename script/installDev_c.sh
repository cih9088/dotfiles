#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install C environment${Color_Off}"

LLVM_VERSION=10.0.0
################################################################

setup_func_local() {
  force=$1
  cd $TMP_DIR

  rm -rf ${HOME}/.local/src/ccls || true
  git clone --depth=1 --recursive https://github.com/MaskRay/ccls ${HOME}/.local/src/ccls

  (
  cd ${HOME}/.local/src/ccls
  if [[ $platform == "OSX" ]]; then
    llvm_target="apple-darwin"
  elif [[ $platform == "LINUX" ]]; then
    llvm_target="linux-gnu-ubuntu-18.04"
  fi

  # download pre-built llvm
  mkdir llvm
  wget https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-${llvm_target}.tar.xz \
    | tar xJ - -C llvm

  # build ccls
  cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=llvm/clang+llvm-${LLVM_VERSION}-x86_64-${llvm_target} \
    -DCMAKE_INSTALL_PREFIX=${HOME}/.local

  # install
  cmake --build Release --target install 
  )

# implemented in vimrc
#     coc_languageserver='
#         "ccls": {
#             "command": "ccls",
#             "filetypes": ["c", "cpp", "objc", "objcpp"],
#             "rootPatterns": [".ccls", "compile_commands.json", ".vim/", ".git/", ".hg/"],
#             "initializationOptions": {
#                 "cacheDirectory": "/tmp/ccls"
#             }
#         }
# '
#
#     # write languageserver, delete empty line first, delete empty line last, insert comma
#     sed -e '/"languageserver":/r '<(echo "${coc_languageserver}") ${PROJ_HOME}/nvim/coc-settings.json | \
#         sed -e '/"languageserver":/{n;d;}' | \
#         tac | sed -e '/^    }$/ N;s/^    }\n$/    }/;' | tac | \
#         sed -e '/"languageserver":/,/^    }$/ s/^[[:space:]]*$/        ,/' > ${TMP_DIR}/tmp
#
#     rm -rf ${PROJ_HOME}/nvim/coc-settings.json || true
#     mv ${TMP_DIR}/tmp ${PROJ_HOME}/nvim/coc-settings.json
}

setup_func_system() {
  force=$1
  cd $TMP_DIR

  if [[ $platform == "OSX" ]]; then
    brew list ccls || brew install ccls
    if [ ${force} == 'true' ]; then
      brew upgrade ccls
    fi
  elif [[ $platform == "LINUX" ]]; then
    # install clang+LLVM with sudo
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

    rm -rf ${HOME}/.local/src/ccls || true
    git clone --depth=1 --recursive https://github.com/MaskRay/ccls ${HOME}/.local/src/ccls
    cd ${HOME}/.local/src/ccls
    cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=/usr/lib/llvm-7 \
      -DLLVM_INCLUDE_DIR=/usr/lib/llvm-7/include \
      -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-7/

    # install
    cmake --build Release --target install 
  fi
}

version_func() {
  $1 --version
}

main_script 'ccls' setup_func_local setup_func_system version_func
