#!/usr/bin/env bash

# change default shell to zsh
while true; do
    echo
    read -p "[?] Do you wish to change default shell to zsh? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[*] Default shell is unchanged..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

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
            chsh -s $(which zsh); break;;
        * ) echo "Please answer locally or systemwide.";;
    esac
done
