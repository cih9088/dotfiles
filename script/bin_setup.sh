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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################


# tree
setup_func_tree() {
    (
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
        fi
    fi
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing tree..."
    echo "${marker_ok} tree installed"
}

# fd
setup_func_fd() {
    (
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
        fi
    fi
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing fd..."
    echo "${marker_ok} fd installed"
}

# thefuck
setup_func_thefuck() {
    (
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
        fi
    fi
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing thefuck..."
    echo "${marker_ok} thefuck installed"
}

# rg
setup_func_rg() {
    (
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
        fi
    fi
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing rg..."
    echo "${marker_ok} rg installed"
}


setup_func_ranger() {
    (
    rm -rf $HOME/.local/src/ranger
    git clone https://github.com/cih9088/ranger $HOME/.local/src/ranger
    $HOME/.local/src/ranger/ranger.py --copy-config=all
    ln -sf $HOME/.local/src/ranger/ranger.py $HOME/.local/bin/ranger
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing ranger..."
    echo "${marker_ok} ranger installed"
}


setup_func_bash_snippets() {
    (
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
    ) >&3 2>&4 &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing bash-snippets (transfer, cheat)..."
    echo "${marker_ok} bash-snippets (transfer, cheat) installed"
}


main() {
    echo
    if [ -x "$(command -v tree)" ]; then
        echo "${marker_info} Following list is tree installed on the system"
        coms=($(which -a tree | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} --version)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} tree is not found"
    fi

    while true; do
        echo "${marker_info} Local install version (installing version: $TREE_VERSION)"
        read -p "${marker_que} Do you wish to install tree? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install tree"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Install locally or sytemwide? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_info} Install tree locally"; setup_func_tree 'local'; break;;
            [Ss]ystem* ) echo "${marker_info} Install tree systemwide"; setup_func_tree; break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done

    echo
    if [ -x "$(command -v fd)" ]; then
        echo "${marker_info} Following list is fd installed on the system"
        coms=($(which -a fd | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} --version)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} fd is not found"
    fi

    while true; do
        echo "${marker_info} Local install version (latest version: $FD_VERSION, installing version: $FD_VERSION)"
        read -p "${marker_que} Do you wish to install fd? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install fd"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Install locally or sytemwide? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_info} Install fd locally"; setup_func_fd 'local'; break;;
            [Ss]ystem* ) echo "${marker_info} Install fd systemwide"; setup_func_fd; break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done

    echo
    if [ -x "$(command -v rg)" ]; then
        echo "${marker_info} Following list is rg installed on the system"
        coms=($(which -a rg | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} --version | head -1)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} rg is not found"
    fi

    while true; do
        echo "${marker_info} Local install version (latest version: $RG_VERSION, installing version: $RG_VERSION)"
        read -p "${marker_que} Do you wish to install ripgrep? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install ripgrep"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Install locally or sytemwide? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_info} Install ripgrep locally"; setup_func_rg 'local'; break;;
            [Ss]ystem* ) echo "${marker_info} Install ripgrep systemwide"; setup_func_rg; break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done

    echo
    if [ -x "$(command -v ranger)" ]; then
        echo "${marker_info} Following list is ranger installed on the system"
        coms=($(which -a ranger | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} --version | head -1)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} ranger is not found"
    fi

    while true; do
        read -p "${marker_que} Do you wish to install ranger? (it will be installed on local) " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install ranger"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        setup_func_ranger
        break
    done

    echo
    if [ -x "$(command -v thefuck)" ]; then
        echo "${marker_info} Following list is thefuck installed on the system"
        coms=($(which -a thefuck | uniq))
        (
            printf 'LOCATION\n'
            for com in "${coms[@]}"; do
                printf '%s\n' "${com}"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} thefuck is not found"
    fi

    while true; do
        read -p "${marker_que} Do you wish to install thefuck? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install thefuck"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Install locally or sytemwide? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_info} Install thefuck locally"; setup_func_thefuck 'local'; break;;
            [Ss]ystem* ) echo "${marker_info} Install thefuck systemwide"; setup_func_thefuck; break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done

    echo
    if [ -x "$(command -v tldr)" ]; then
        echo "${marker_info} Following list is tldr installed on the system"
        coms=($(which -a tldr | uniq))
        (
            printf 'LOCATION\n'
            for com in "${coms[@]}"; do
                printf '%s\n' "${com}"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} tldr is not found"
    fi

    while true; do
        read -p "${marker_que} Do you wish to install tldr? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install tldr"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Install locally or sytemwide? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_info} Install tldr locally";
                (pip install tldr --user) >&3 2>&4 &
                [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing tldr..."
                echo "${marker_ok} tldr installed"
                break;;
            [Ss]ystem* ) echo "${marker_info} Install tldr systemwide"; 
                (
                if [[ $platform == "OSX" ]]; then
                    brew bundle --file=- <<EOS
brew 'tldr'
EOS
                elif [[ $platform == "LINUX" ]]; then
                    sudo pip install tldr
                fi
                ) >&3 2>&4 &
                [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing tldr..."
                echo "${marker_ok} tldr installed"
                break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done

    echo
    while true; do
        read -p "${marker_que} Do you wish to install bash-snippets? " yn
        case $yn in
            [Yy]* ) :; ;;
            [Nn]* ) echo "${marker_err} Aborting install bash-snippets"; break;;
            * ) echo "${marker_err} Please answer yes or no"; continue;;
        esac

        read -p "${marker_que} Install locally or systemwide? " yn
        case $yn in
            [Ll]ocal* ) echo "${marker_info} Install bash-snippets locally"; setup_func_bash_snippets 'local'; break;;
            [Ss]ystem* ) echo "${marker_info} Install bash-snippets systemwide"; setup_func_bash_snippets; break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done


    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}

        echo
main "$@"
