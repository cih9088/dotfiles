#!/bin/zsh
# backup old files
mkdir ~/dotfiles_old
cp ~/.vimrc ~/dotfiles_old
cp ~/.tmux.conf ~/dotfiles_old
cp ~/.zshrc ~/dotfiles_old
cp ~/.zpreztorc ~/dotfiles_old

# Copy dot files
\cp vimrc ~/.vimrc
\cp tmux.conf ~/.tmux.conf
\cp zshrc ~/.zshrc
\cp zpreztorc ~/.zpreztorc
