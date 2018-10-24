#!/bin/bash

# change version you want to install on local
TREE_VERSION=1.7.0

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

case "$OSTYPE" in
    solaris*) platform="SOLARIS" ;;
    darwin*)  platform="OSX" ;;
    linux*)   platform="LINUX" ;;
    bsd*)     platform="BSD" ;;
    msys*)    platform="WINDOWS" ;;
    *)        platform="unknown: $OSTYPE" ;;
esac

if [[ $$ = $BASHPID ]]; then
    PROJ_HOME=$(git rev-parse --show-toplevel)
    TMP_DIR=$HOME/tmp_install

    if [ ! -d $HOME/.local/bin ]; then
        mkdir -p $HOME/.local/bin
    fi

    if [ ! -d $HOME/.local/src ]; then
        mkdir -p $HOME/.local/src
    fi

    if [ ! -d $TMP_DIR ]; then
        mkdir -p $TMP_DIR
    fi
fi
BIN_DIR=${PROJ_HOME}/bin


# tree
setup_func_tree() {
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        wget http://mama.indstate.edu/users/ice/tree/src/tree-${TREE_VERSION}.tgz
        tar -xvzf tree-${TREE_VERSION}.tgz
        cd tree-${TREE_VERSION}
        sed -i -e "s|prefix = /usr|prefix = $HOME/.local|" Makefile
        make
        make install
        cd $TMP_DIR
        rm -rf $HOME/.local/src/tree-*
        mv tree-${TREE_VERSION} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            # brew install tree
            brew bundle --file=- <<EOS
brew 'tree'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get -y install tree
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] tree command installed..."
}

# fd
setup_func_fd() {
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-apple-darwin.tar.gz
            tar -xvzf fd-v${FD_VERSION}-x86_64-apple-darwin.tar.gz
            cd fd-v${FD_VERSION}-x86_64-apple-darwin
            cp fd $HOME/.local/bin
            cp fd.1 $HOME/.local/man/man1
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            tar -xvzf fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz
            cd fd-v${FD_VERSION}-x86_64-unknown-linux-gnu
            cp fd $HOME/.local/bin
            cp fd.1 $HOME/.local/man/man1
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    else
        if [[ $platform == "OSX" ]]; then
            # brew install fd
            brew bundle --file=- <<EOS
brew 'fd'
EOS
        elif [[ $platform == "LINUX" ]]; then
            cd $TMP_DIR
            wget https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb
            sudo dpkg -i fd_${FD_VERSION}_amd64.deb
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] fd command installed..."
}

# thefuck
setup_func_thefuck() {
    if [[ $1 = local ]]; then
        pip3 install thefuck --user
    else
        if [[ $platform == "OSX" ]]; then
            # brew install thefuck
            brew bundle --file=- <<EOS
brew 'thefuck'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo pip3 install thefuck
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] thefuck command installed..."
}

# rg
setup_func_rg() {
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
            tar -xvzf ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz
            cd ripgrep-${RG_VERSION}-x86_64-apple-darwin
            cp rg $HOME/.local/bin
            cp doc/rg.1 $HOME/.local/man/man1
        elif [[ $platform == "LINUX" ]]; then
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
            tar -xvzf ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
            cd ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl
            cp rg $HOME/.local/bin
            cp doc/rg.1 $HOME/.local/man/man1
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    else
        if [[ $platform == "OSX" ]]; then
            # brew install ripgrep
            brew bundle --file=- <<EOS
brew 'ripgrep'
EOS
        elif [[ $platform == "LINUX" ]]; then
            cd $TMP_DIR
            wget https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb
            sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb
        else
            echo "[!] $platform is not supported."; exit 1
        fi
    fi

    echo "[*] rg command installed..."
}


setup_func_ranger() {
    rm -rf $HOME/.local/src/ranger
    git clone https://github.com/cih9088/ranger $HOME/.local/src/ranger
    $HOME/.local/src/ranger/ranger.py --copy-config=all
    ln -sf $HOME/.local/src/ranger/ranger.py $HOME/.local/bin/ranger
}


setup_func_bash_snippets() {
    cd $TMP_DIR
    git clone https://github.com/alexanderepstein/Bash-Snippets
    cd Bash-Snippets

    if [[ $1 = local ]]; then
        ./install.sh --prefix=$HOME/.local transfer cheat
    else
        if [[ $platform == "OSX" ]]; then
            brew bundle --file=- <<EOS
brew "bash-snippets", args: ["with-cheat", "with-transfer", "without-all-tools"]
EOS
        elif [[ $platform == "LINUX" ]]; then
            ./install.sh transfer cheat
        fi

    fi

    echo "[*] bash-snippets (transfer, cheat) command installed..."
}


while true; do
    echo
    if [ -x "$(command -v tree)" ]; then
        echo "[*] Following list is tree insalled on the system"
        type tree
        echo
        echo "[*] Your tree version is...."
        tree --version
    else
        echo "[*] tree is not found"
    fi

    echo
    echo "[*] Local install version (installing version: $TREE_VERSION)"
    read -p "[?] Do you wish to install tree? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install tree..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install tree locally..."; setup_func_tree 'local'; break;;
        [Ss]ystem* ) echo "[*] Install tree systemwide..."; setup_func_tree; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    if [ -x "$(command -v fd)" ]; then
        echo "[*] Following list is fd insalled on the system"
        type fd
        echo
        echo "[*] Your fd version is...."
        fd --version
    else
        echo "[*] fd is not found"
    fi

    echo
    echo "[*] Local install version (latest version: $FD_VERSION, installing version: $FD_VERSION)"
    read -p "[?] Do you wish to install fd? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install fd..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install fd locally..."; setup_func_fd 'local'; break;;
        [Ss]ystem* ) echo "[*] Install fd systemwide..."; setup_func_fd; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    if [ -x "$(command -v rg)" ]; then
        echo "[*] Following list is rg insalled on the system"
        type rg
        echo
        echo "[*] Your rg version is...."
        rg --version
    else
        echo "[*] rg is not found"
    fi

    echo
    echo "[*] Local install version (latest version: $RG_VERSION, installing version: $RG_VERSION)"
    read -p "[?] Do you wish to install ripgrep? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install ripgrep..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install ripgrep locally..."; setup_func_rg 'local'; break;;
        [Ss]ystem* ) echo "[*] Install ripgrep systemwide..."; setup_func_rg; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    read -p "[?] Do you wish to install ranger? (it will be installed on local) " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install ranger..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    setup_func_ranger
    break
done


while true; do
    echo
    read -p "[?] Do you wish to install thefuck? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install thefuck..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install thefuck locally..."; setup_func_thefuck 'local'; break;;
        [Ss]ystem* ) echo "[*] Install thefuck systemwide..."; setup_func_thefuck; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    read -p "[?] Do you wish to install tldr? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install tldr..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or sytemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install tldr locally..."; pip install tldr --user; break;;
        [Ss]ystem* ) echo "[*] Install tldr systemwide..."; 
            if [[ $platform == "OSX" ]]; then
                brew bundle --file=- <<EOS
brew 'tldr'
EOS
            elif [[ $platform == "LINUX" ]]; then
                sudo pip install tldr
            else
                echo "[!] $platform is not supported."; exit 1
            fi
            break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


while true; do
    echo
    read -p "[?] Do you wish to install bash-snippets? " yn
    case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) echo "[!] Aborting install bash-snippets..."; break;;
        * ) echo "Please answer yes or no."; continue;;
    esac

    read -p "[?] Install locally or systemwide? " yn
    case $yn in
        [Ll]ocal* ) echo "[*] Install bash-snippets locally..."; setup_func_bash_snippets 'local'; break;;
        [Ss]ystem* ) echo "[*] Install bash-snippets systemwide..."; setup_func_bash_snippets; break;;
        * ) echo "Please answer locally or systemwide."; continue;;
    esac
done


# clean up
if [[ $$ = $BASHPID ]]; then
    rm -rf $TMP_DIR
fi
