#!/bin/bash

set -e

case "$OSTYPE" in
    solaris*) platform='SOLARIS' ;;
    darwin*)  platform='OSX' ;;
    linux*)   platform='LINUX' ;;
    bsd*)     platform='BSD' ;;
    msys*)    platform='WINDOWS' ;;
    *)        platform='unknown: $OSTYPE' ;;
esac

if [[ $platform == "OSX" ]]; then
    echo "[*] Your platform is OSX"
elif [[ $platform == "LINUX" ]]; then
    echo "[*] Your platform is LINUX"
else
    echo "[!] $platform is not supported."; exit 1
fi

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


########################################################################
# install prezto #
########################################################################

# install zsh
( . $SCRIPTS/zsh_setup.sh )

# install prezto
$SCRIPTS/prezto_setup.sh

# change default shell to zsh
while true; do
    echo
    read -p "[?] Do you wish to change default shell to zsh? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[*] Default shell is unchanged..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    echo
    read -p "[?] Change default shell to local zsh or systemwide zsh? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Changing default shell to local zsh..."
            if grep -Fxq "exec $HOME/.local/bin/zsh -l" $HOME/.bashrc; then
                :
            else
                echo "exec $HOME/.local/bin/zsh -l" >> $HOME/.bashrc
            fi
            break;;
        [Ss]ystem* ) echo "[*] Changing default shell to systemwide zsh..."
            chsh -s /bin/zsh; break;;
        * ) echo "Please answer locally or systemwide.";;
    esac
done


########################################################################
# install dotfiles #
########################################################################

( . $SCRIPTS/dot_setup.sh )



########################################################################
# install neovim #
########################################################################

# install neovim
( . $SCRIPTS/nvim_setup.sh )

# install neovim with python support
echo
echo '[*] Install neovim with python support'
sleep 1
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


########################################################################
# install tmux #
########################################################################

( . $SCRIPTS/tmux_setup.sh )



########################################################################
# install bin #
########################################################################

( . $SCRIPTS/bin_setup.sh )


# clean up
if [ -d $TMP_DIR ]; then
    rm -rf $TMP_DIR
fi



########################################################################
# install etc #
########################################################################

pip install glances --user
pip install gpustat --user
pip install grip --user



# Install plugins in neovim and vim
echo
echo '[*] Install plugins in neovim'
sleep 1
nvim +PlugInstall +UpdateRemotePlugins +qall
# vim +PlugInstall +qall

echo '[*] Install is finished!!!'
