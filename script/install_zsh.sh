#!/usr/bin/env bash

# change version you want to install on local
ZSH_VERSION=5.6.2

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

setup_func() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing zsh..."
    (
    if [[ $1 = local ]]; then
        if [ -d $HOME/.local/src/zsh-* ]; then
            cd $HOME/.local/src/zsh-*
            make uninstall
            make clean
            cd ..
            rm -rf $HOME/.local/src/zsh-*
        fi
        cd $TMP_DIR
        wget http://www.zsh.org/pub/zsh-${ZSH_VERSION}.tar.xz
        tar -xvJf zsh-${ZSH_VERSION}.tar.xz
        cd zsh-${ZSH_VERSION}
        ./configure --prefix=$HOME/.local
        make || exit $?
        make install || exit $?
        cd $TMP_DIR
        mv zsh-${ZSH_VERSION} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            # brew install zsh
            brew bundle --file=- <<EOS
brew 'zsh'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get -y install zsh
            # Adding installed zsh to /etc/shells
            if grep -Fxq "/usr/bin/zsh" /etc/shells; then
                :
            else
                echo "/usr/bin/zsh" | sudo tee -a /etc/shells
            fi
        fi
    fi
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "zsh is installed [$1]" \
        "zsh install is failed [$1]. use VERBOSE=YES for error message"
}

main() {
    echo
    if [ -x "$(command -v zsh)" ]; then
        echo "${marker_info} Following list is zsh installed on the system"
        coms=($(which -a zsh | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} --version)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_info} zsh is not found"
    fi
    echo "${marker_info} Local install version (installing version: $ZSH_VERSION)"

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_zsh_install} == "yes" ]]; then
            [[ ${CONFIG_zsh_local} == "yes" ]] && setup_func 'local' || setup_func 'system'
        else
            echo "${marker_ok} zsh is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install zsh? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install zsh"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install zsh ${ZSH_VERSION} locally"; setup_func 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install latest zsh systemwide"; setup_func 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}

main "$@"
