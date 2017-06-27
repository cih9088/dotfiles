#!/bin/bash
# exit on error
set -e

VERSION=2.5

case "$OSTYPE" in
    solaris*) platform='SOLARIS' ;;
    darwin*)  platform='OSX' ;; 
    linux*)   platform='LINUX' ;;
    bsd*)     platform='BSD' ;;
    msys*)    platform='WINDOWS' ;;
    *)        platform='unknown: $OSTYPE' ;;
esac


if [[ $1 = local ]]; then
    echo 'Build "libevent-dev" and "libncurses-dev".' >&2
else
    if [[ $platform == "LINUX" ]]; then
        sudo apt-get -y install libevent-dev libncurses-dev
        sudo apt-get -y remove tmux
    elif [[ $platform == "OSX" ]]; then
        brew install libevent ncurses
        brew install wget
        brew uninstall tmux
    else
        print 'Not defined'
    fi
fi

wget https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz
tar -xvzf tmux-${VERSION}.tar.gz
rm -f tmux-${VERSION}.tar.gz
cd tmux-${VERSION}

if [[ $1 = local ]]; then
    ./configure --prefix=$HOME/local
    make
    make install
    mkdir -p $HOME/local/src
    cd -
    rm -rf $HOME/local/src/tmux-*
    mv tmux-${VERSION} $HOME/local/src
else
    ./configure
    make
    sudo make install
    cd -
    sudo rm -rf /usr/local/src/tmux-*
    sudo mv tmux-${VERSION} /usr/local/src
fi
