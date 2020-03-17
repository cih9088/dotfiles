#!/usr/bin/env bash

# change version you want to install on local
TREE_VERSION=1.8.0

FD_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/sharkdp/fd/releases/latest" |
     grep '"tag_name":' |
     sed -E 's/.*"([^"]+)".*/\1/')
FD_LATEST_VERSION=${FD_LATEST_VERSION##v}
FD_VERSION=${1:-${FD_LATEST_VERSION}}

RG_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" |
     grep '"tag_name":' |
     sed -E 's/.*"([^"]+)".*/\1/')
RG_LATEST_VERSION=${RG_LATEST_VERSION##v}
RG_VERSION=${1:-${RG_LATEST_VERSION}}

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

setup_func_tree_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -d $HOME/.local/src/tree-* ]; then
        if [ ${force} == 'yes' ]; then
            cd $HOME/.local/src/tree-*
            make clean || true
            cd ..
            rm -rf $HOME/.local/src/tree-*
            install=yes
        fi
    else
        install=yes
    fi

    if [ ${instal} == 'yes' ]; then
        cd $TMP_DIR
        wget http://mama.indstate.edu/users/ice/tree/src/tree-${TREE_VERSION}.tgz
        tar -xvzf tree-${TREE_VERSION}.tgz
        cd tree-${TREE_VERSION}
        sed -i -e "s|prefix = /usr|prefix = $HOME/.local|" Makefile
        make || exit $?
        make install || exit $?
        cd $TMP_DIR
        rm -rf $HOME/.local/src/tree-*
        mv tree-${TREE_VERSION} $HOME/.local/src
    fi
}

setup_func_tree_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install tree
    elif [[ $platform == "LINUX" ]]; then
        sudo apt-get -y install tree
    fi
}

version_func_tree() {
    $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

setup_func_fd_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -f ${HOME}/.local/bin/fd ]; then
        if [ ${force} == 'yes' ]; then
            rm -rf $HOME/.local/bin/fd || true
            rm -rf $HOME/.local/man/man1/fd.1 || true
            install=yes
        fi
    else
        install=yes
    fi

    if [ ${install} == 'yes' ]; then
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-apple-darwin.tar.gz
            tar -xvzf fd-v${FD_VERSION}-x86_64-apple-darwin.tar.gz
            cd fd-v${FD_VERSION}-x86_64-apple-darwin
            yes | \cp -rf fd $HOME/.local/bin
            yes | \cp -rf fd.1 $HOME/.local/man/man1
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            tar -xvzf fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            cd fd-v${FD_VERSION}-x86_64-unknown-linux-gnu
            yes | \cp -rf fd $HOME/.local/bin
            yes | \cp -rf fd.1 $HOME/.local/man/man1
        fi
    fi
}

setup_func_fd_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install fd
    elif [[ $platform == "LINUX" ]]; then
        cd $TMP_DIR
        wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb
        sudo dpkg -i fd_${FD_VERSION}_amd64.deb
    fi
}

version_func_fd() {
    $1 --version | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

setup_func_thefuck_local() {
    force=$1
    cd $TMP_DIR

    if [ ${force} == 'yes' ]; then
        pip3 install thefuck --user --force-reinstall --upgrade
    else
        pip3 install thefuck --user
    fi
}

setup_func_thefuck_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install thefuck
    elif [[ $platform == "LINUX" ]]; then
        sudo pip3 install thefuck --upgrade --force-reinstall
    fi
}

version_func_thefuck() {
    $1 --version
}

setup_func_rg_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -f ${HOME}/.local/bin/rg ]; then
        if [ ${force} == 'yes' ]; then
            rm -rf $HOME/.local/bin/rg || true
            rm -rf $HOME/.local/man/man1/rg.1 || true
            install=yes
        fi
    else
        install=yes
    fi

    if [ ${install} == 'yes' ]; then
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
            tar -xvzf ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
            cd ripgrep-${RG_VERSION}-x86_64-apple-darwin
            yes | \cp -rf rg $HOME/.local/bin
            yes | \cp -rf doc/rg.1 $HOME/.local/man/man1
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
            tar -xvzf ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
            cd ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl
            yes | \cp -rf rg $HOME/.local/bin
            yes | \cp -rf doc/rg.1 $HOME/.local/man/man1
        fi
    fi
}

setup_func_rg_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install ripgrep
    elif [[ $platform == "LINUX" ]]; then
        cd $TMP_DIR
        wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
        sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
    fi
}

version_func_rg() {
    $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

setup_func_ranger_local() {
    force=$1
    cd $TMP_DIR

    install=no
    if [ -f ${HOME}/.local/bin/ranger ]; then
        if [ ${force} == 'yes' ]; then
            rm -rf $HOME/.local/src/ranger || true
            rm -rf $HOME/.local/bin/ranger || true
            install=yes
        fi
    else
        install=yes
    fi

    if [ ${install} == 'yes' ]; then
        git clone https://github.com/ranger/ranger.git $HOME/.local/src/ranger
        # git clone https://github.com/cih9088/ranger $HOME/.local/src/ranger
        $HOME/.local/src/ranger/ranger.py --copy-config=all
        ln -sf $HOME/.local/src/ranger/ranger.py $HOME/.local/bin/ranger
    fi
}

setup_func_ranger_system() {
    setup_func_ranger_local $1
}

version_func_ranger() {
    $1 --version | head -1 | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'
}

setup_func_tldr_local() {
    force=$1
    cd $TMP_DIR

    if [ ${force} == 'yes' ]; then
        pip install tldr --user --force-reinstall --upgrade
    else
        pip install tldr --user
    fi
}

setup_func_tldr_system() {
    force=$1
    cd $TMP_DIR

    if [[ $platform == "OSX" ]]; then
        brew install tldr
    elif [[ $platform == "LINUX" ]]; then
        sudo pip install tldr --upgrade --force-reinstall
    fi
}

version_func_tldr() {
    $1 --version | head -1 | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
}

setup_func_bash_snippets_local() {
    force=$1
    cd $TMP_DIR

    git clone https://github.com/alexanderepstein/Bash-Snippets
    cd Bash-Snippets

    ./install.sh --prefix=$HOME/.local transfer cheat
}

setup_func_bash_snippets_system() {
    force=$1
    cd $TMP_DIR

    git clone https://github.com/alexanderepstein/Bash-Snippets
    cd Bash-Snippets

    if [[ $platform == "OSX" ]]; then
        brew install bash-snippets
    elif [[ $platform == "LINUX" ]]; then
        ./install.sh transfer cheat
    fi
}

main_script 'tree' setup_func_tree_local setup_func_tree_system version_func_tree

main_script 'fd' setup_func_fd_local setup_func_fd_system version_func_fd

main_script 'rg' setup_func_rg_local setup_func_rg_system version_func_rg

main_script 'ranger' setup_func_ranger_local setup_func_ranger_system version_func_ranger

main_script 'thefuck' setup_func_thefuck_local setup_func_thefuck_system version_func_thefuck

main_script 'tldr' setup_func_tldr_local setup_func_tldr_system version_func_tldr

main_script 'bash_snippets' setup_func_bash_snippets_local setup_func_bash_snippets_system
