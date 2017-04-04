#!/bin/zsh
# backup old files
\mkdir ~/dotfiles_old
\cp ~/.vimrc ~/dotfiles_old
\cp ~/.tmux.conf ~/dotfiles_old
\cp ~/.zshrc ~/dotfiles_old
\cp ~/.zpreztorc ~/dotfiles_old

# Copy dot files
\cd ~
\ln -s -f dotfiles/vimrc ~/.vimrc
\ln -s -f dotfiles/tmux.conf ~/.tmux.conf
\ln -s -f dotfiles/tmux.conf.local ~/.tmux.conf.local
\ln -s -f dotfiles/zshrc ~/.zshrc
\ln -s -f dotfiles/zpreztorc ~/.zpreztorc
