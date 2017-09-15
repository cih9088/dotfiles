#!/bin/bash

# YCM setup (https://github.com/Valloric/YouCompleteMe)
sudo apt-get install build-essential cmake
sudo apt-get install python-dev python3-dev
cd ~/.vim/plugged/YouCompleteMe
./install.py --clang-completer

# ag install (https://github.com/ggreer/the_silver_searcher)
# for Ubuntu and Debian
sudo apt-get install silversearcher-ag
