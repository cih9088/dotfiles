#!/bin/zsh
# Clone vim-plug repository
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install Plugins from command line
vim +PlugInstall +qall
