#!/bin/zsh
# Original URL of prezto
# htts://github.com/sorin-ionescu/prezto

setup_func() {
    # Clone prezto the repository
    #git clone --recursive https://github.com/cih9088/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

    # Create a new zsh configureation by copying the zsh config files
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
        ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done

    ## Clone garrett prompt repository
    #git clone https://github.com/cih9088/zsh-prompt-garrett.git ./prompt
    #
    #cd prompt
    #cp prompt_garrett_setup ~/.zprezto/modules/prompt/functions/
    #cd ..
    #rm -rf prompt
    
    echo "[*] prezto installed..."
}

while true; do
    echo
    read "yn?[?] Do you wish to install prezto? "
    # vared -p "Do you wish to install prezto? " -c yn
    case $yn in
        [Yy]* ) echo "[*] Installing prezto..."; setup_func; break;;
        [Nn]* ) echo "[!] Aborting install prezto..."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
