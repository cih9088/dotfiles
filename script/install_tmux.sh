#!/usr/bin/env bash

# change version you want to install on local
LIBEVENT_VERSION=2.1.12
NCURSES_VERSION=6.2
XCLIP_VERSION=0.12

# based on https://gist.github.com/ryin/3106801#gistcomment-2191503
# tmux will be installed in $HOME/.local/bin if you specify to install without root access
# It's assumed that wget and a C/C++ compiler are installed.

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

echo
echo "${marker_title} Prepare to ${Bold}${Underline}install tmux${Color_Off}"

TARGET="tmux"
TMUX_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release tmux/tmux)"
TMUX_VERSION=${1:-${TMUX_LATEST_VERSION}}
$(${PROJ_HOME}/script/check_release tmux/tmux ${TMUX_VERSION}) || exit $?
################################################################

setup_func_local() {
    force=$1
    cd $TMP_DIR

    # libevent
    if [ -d $HOME/.local/src/libevent-* ]; then
        cd $HOME/.local/src/libevent-*
        make uninstall
        make clean
        cd ..
        rm -rf $HOME/.local/src/libevent-*
    fi
    cd $TMP_DIR
    wget https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz
    tar -xvzf libevent-${LIBEVENT_VERSION}-stable.tar.gz
    cd libevent-${LIBEVENT_VERSION}-stable
    ./configure --prefix=$HOME/.local --disable-shared
    make || exit $?
    make install || exit $?
    cd $TMP_DIR
    mv libevent-${LIBEVENT_VERSION}-stable $HOME/.local/src

    # ncurses
    if [ -d $HOME/.local/src/ncurses-* ]; then
        cd $HOME/.local/src/ncurses-*
        make uninstall
        cd ..
        rm -rf $HOME/.local/src/ncurses-*
    fi
    cd $TMP_DIR
    wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
    tar -xvzf ncurses-${NCURSES_VERSION}.tar.gz
    cd ncurses-${NCURSES_VERSION}
    ./configure --prefix=$HOME/.local
    make || exit $?
    make install || exit $?
    cd $TMP_DIR
    mv ncurses-${NCURSES_VERSION} $HOME/.local/src

    install=no
    if [ -f ${HOME}/.local/bin/tmux ]; then
        if [ ${force} == 'true' ]; then
            if [ -d $HOME/.local/src/tmux-* ]; then
                cd $HOME/.local/src/tmux-*
                make uninstall || true
                make clean || true
                cd ..
                rm -rf $HOME/.local/src/tmux-*
            fi
            install=true
        fi
    else
        install=true
    fi

    if [ ${install} == 'true' ]; then
        cd $TMP_DIR
        wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
        tar -xvzf tmux-${TMUX_VERSION}.tar.gz
        cd tmux-${TMUX_VERSION}
        ./configure CFLAGS="-I$HOME/.local/include -I$HOME/.local/include/ncurses" LDFLAGS="-L$HOME/.local/lib -L$HOME/.local/include/ncurses -L$HOME/.local/include" --prefix=$HOME/.local
        (CPPFLAGS="-I$HOME/.local/include -I$HOME/.local/include/ncurses" LDFLAGS="-static -L$HOME/.local/include -L$HOME/.local/include/ncurses -L$HOME/.local/lib" make)
        make install || exit $?
        mv tmux $HOME/.local/bin
        cd $TMP_DIR
        mv tmux-${TMUX_VERSION} $HOME/.local/src
    fi
}

setup_func_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install libevent ncurses
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get -y remove libevent-dev libncurses-dev
        sudo apt-get -y install libevent-dev libncurses-dev
    fi

    if [[ $platform == "OSX" ]]; then
        brew install reattach-to-user-namespace
        brew install tmux
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get -y remove tmux
        sudo apt-get -y install tmux
    fi

}

version_func() {
    $1 -V | awk '{print $2}'
}

main_script ${TARGET} setup_func_local setup_func_system version_func
