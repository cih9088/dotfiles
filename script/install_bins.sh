#!/usr/bin/env bash

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
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing tree..."
    (
    if [[ $1 = local ]]; then
        if [ -d $HOME/.local/src/tree-* ]; then
            cd $HOME/.local/src/tree-*
            make clean
            cd ..
            rm -rf $HOME/.local/src/tree-*
        fi
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
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "tree is installed [$1]" \
        "tree install is failed [$1]. use VERBOSE=YES for error message"
}

# fd
setup_func_fd() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing fd..."
    (
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        rm -rf $HOME/.local/bin/fd || true
        rm -rf $HOME/.local/man/man1/fd.1 || true
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
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "fd is installed [$1]" \
        "fd install is failed [$1]. use VERBOSE=YES for error message"
}

# thefuck
setup_func_thefuck() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing thefuck..."
    (
    if [[ $1 = local ]]; then
        pip3 install thefuck --user --upgrade
    else
        if [[ $platform == "OSX" ]]; then
            # brew install thefuck
            brew bundle --file=- <<EOS
brew 'thefuck'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo pip3 install thefuck --upgrade
        fi
    fi
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "thefuck is installed [$1]" \
        "thefuck install is failed [$1]. use VERBOSE=YES for error message"
}

# rg
setup_func_rg() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing rg..."
    (
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        rm -rf $HOME/.local/bin/rg || true
        rm -rf $HOME/.local/man/man1/rg.1 || true
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
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "rg is installed [$1]" \
        "rg install is failed [$1]. use VERBOSE=YES for error message"
}


setup_func_ranger() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing ranger..."
    (
    rm -rf $HOME/.local/src/ranger || true
    rm -rf $HOME/.local/bin/ranger || true
    git clone https://github.com/ranger/ranger.git $HOME/.local/src/ranger
    # git clone https://github.com/cih9088/ranger $HOME/.local/src/ranger
    $HOME/.local/src/ranger/ranger.py --copy-config=all
    ln -sf $HOME/.local/src/ranger/ranger.py $HOME/.local/bin/ranger
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "ranger is installed [local]" \
        "ranger install is failed [local]. use VERBOSE=YES for error message"
}

# tldr
setup_func_tldr() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing tldr..."
    (
    if [[ $1 == local ]]; then
        pip install tldr --user --upgrade
    else
        if [[ $platform == "OSX" ]]; then
            brew bundle --file=- <<EOS
brew 'tldr'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo pip install tldr --upgrade
        fi
    fi
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "tldr is installed [$1]" \
        "tldr install is failed [$1]. use VERBOSE=YES for error message"
}

setup_func_bash_snippets() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing bash-snippets..."
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
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "bash-snippets (transfer, cheat) is installed [$1]" \
        "bash-snippets (transfer, cheat) install is failed [$1]. use VERBOSE=YES for error message"
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
        echo "${marker_info} tree is not found"
    fi
    echo "${marker_info} Local install version (installing version: $TREE_VERSION)"

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_tree_install} == "yes" ]]; then
            [[ ${CONFIG_tree_local} == "yes" ]] && setup_func_tree 'local' || setup_func_tree 'system'
        else
            echo "${marker_ok} tree is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install tree? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install tree"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install tree locally"; setup_func_tree 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install tree systemwide"; setup_func_tree 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

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
        echo "${marker_info} fd is not found"
    fi
    echo "${marker_info} Local install version (latest version: $FD_VERSION, installing version: $FD_VERSION)"

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_fd_install} == "yes" ]]; then
            [[ ${CONFIG_fd_local} == "yes" ]] && setup_func_fd 'local' || setup_func_fd 'system'
        else
            echo "${marker_ok} fd is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install fd? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install fd"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install fd locally"; setup_func_fd 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install fd systemwide"; setup_func_fd 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

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
        echo "${marker_info} rg is not found"
    fi
    echo "${marker_info} Local install version (latest version: $RG_VERSION, installing version: $RG_VERSION)"

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_rg_install} == "yes" ]]; then
            [[ ${CONFIG_rg_local} == "yes" ]] && setup_func_rg 'local' || setup_func_rg 'system'
        else
            echo "${marker_ok} rg is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install ripgrep? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install ripgrep"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install ripgrep locally"; setup_func_rg 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install ripgrep systemwide"; setup_func_rg 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

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
        echo "${marker_info} ranger is not found"
    fi

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_ranger_install} == "yes" ]]; then
            setup_func_ranger
        else
            echo "${marker_ok} rg is not installed"
        fi
    else
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
    fi

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
        echo "${marker_info} thefuck is not found"
    fi

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_thefuck_install} == "yes" ]]; then
            [[ ${CONFIG_thefuck_local} == "yes" ]] && setup_func_thefuck 'local' || setup_func_thefuck 'system'
        else
            echo "${marker_ok} thefuck is not installed"
        fi
    else
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
                [Ss]ystem* ) echo "${marker_info} Install thefuck systemwide"; setup_func_thefuck 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

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
        echo "${marker_info} tldr is not found"
    fi

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_tldr_install} == "yes" ]]; then
            [[ ${CONFIG_tldr_local} == "yes" ]] && setup_func_tldr 'local' || setup_func_tldr 'system'
        else
            echo "${marker_ok} tldr is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install tldr? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install tldr"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install tldr locally"; setup_func_tldr 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install tldr systemwide"; setup_func_tldr 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

    echo
    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_bash_snippets_install} == "yes" ]]; then
            [[ ${CONFIG_bash_snippets_local} == "yes" ]] && setup_func_bash_snippets 'local' || setup_func_bash_snippets 'system'
        else
            echo "${marker_ok} bash_snippets is not installed"
        fi
    else
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
                [Ss]ystem* ) echo "${marker_info} Install bash-snippets systemwide"; setup_func_bash_snippets 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}

        echo
main "$@"
