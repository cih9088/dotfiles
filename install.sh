#!/bin/bash

set -e

PROJ_HOME=$(pwd)
TMP_DIR=$HOME/tmp_install
SCRIPTS=$PROJ_HOME/script

if [ ! -d $HOME/.local/bin ]; then
    mkdir -p $HOME/.local/bin
fi

if [ ! -d $HOME/.local/src ]; then
    mkdir -p $HOME/.local/src
fi

if [ ! -d $TMP_DIR ]; then
    mkdir -p $TMP_DIR
fi

case "$OSTYPE" in
    solaris*) platform='SOLARIS' ;;
    darwin*)  platform='OSX' ;;
    linux*)   platform='LINUX' ;;
    bsd*)     platform='BSD' ;;
    msys*)    platform='WINDOWS' ;;
    *)        platform='unknown: $OSTYPE' ;;
esac


########################################################################
# install prezto #
########################################################################

# install zsh
( . $SCRIPTS/zsh_setup.sh )

# install prezto
$SCRIPTS/prezto_setup.sh

# change default shell to zsh
echo '\n[*] chaning default shell to zsh'
if [[ $1 = local ]]; then
    chsh -s $HOME/.local/bin/zsh
else
    chsh -s /bin/zsh
fi


########################################################################
# install neovim #
########################################################################

# install neovim
( . $SCRIPTS/nvim_setup.sh )

# install neovim with python support
pip3 install neovim --upgrade --user
pip2 install neovim --upgrade --user
# while true; do
#     read -p "\nDo you wish to install neovim with virtualenv ? " yn
#     case $yn in
#         [Yy]* )
#             break;;
#         [Nn]* )
#             pip3 install neovim --upgrade --user
#             pip2 install neovim --upgrade --user
#             break;;
#         * ) echo "Please answer yes or no.";;
#     esac
# done

( . $SCRIPTS/tmux_setup.sh )
( . $SCRIPTS/bin_setup.sh )
# ( . $SCRIPTS/dot_setup.sh )
# ( . $SCRIPTS/setup_env.sh )
