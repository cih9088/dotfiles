#!/bin/bash

NVIM_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/neovim/neovim/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')
NVIM_LATEST_VERSION=${NVIM_LATEST_VERSION##v}
NVIM_VERSION=${1:-${NVIM_LATEST_VERSION}}

XCLIP_VERSION=0.12

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

setup_func_neovim() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing neovim..."
    (
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            wget https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-macos.tar.gz
            tar -xvzf nvim-macos.tar.gz
            yes | \cp -rf nvim-osx64/* $HOME/.local/
        elif [[ $platform == "LINUX" ]]; then
            rm -rf $HOME/.local/bin/nvim || true
            rm -rf $HOME/.local/man/man1/nvim.1 || true
            rm -rf $HOME/.local/share/nvim/runtim || true
            # https://github.com/neovim/neovim/issues/7620
            # https://github.com/neovim/neovim/issues/7537
            wget https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim.appimage
            chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract
            yes | \cp -rf squashfs-root/usr/bin $HOME/.local
            yes | \cp -rf squashfs-root/usr/man $HOME/.local
            yes | \cp -rf squashfs-root/usr/share/nvim $HOME/.local/share
            # yes | \cp -rf squashfs-root/usr/* $HOME/.local
            # chmod u+x nvim.appimage && mv nvim.appimage nvim
            # cp nvim $HOME/.local/bin
        fi
    else
        if [[ $platform == "OSX" ]]; then
            # brew install neovim
            brew bundle --file=- <<EOS
brew 'neovim'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get install software-properties-common
            sudo add-apt-repository ppa:neovim-ppa/stable
            sudo apt-get update
            sudo apt-get install neovim
        fi
    fi
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "neovim is installed [$1]" \
        "neovim install is failed [$1]. use VERBOSE=YES for error message"

    # (
    # if [[ $1 = local ]]; then
    #     if [ -d $HOME/.local/src/xclip-* ]; then
    #         cd $HOME/.local/src/xclip-*
    #         make uninstall
    #         make clean
    #         cd ..
    #         rm -rf $HOME/.local/src/xclip-*
    #     fi
    #     cd $TMP_DIR
    #     wget http://kent.dl.sourceforge.net/project/xclip/xclip/${XCLIP_VERSION}/xclip-${XCLIP_VERSION}.tar.gz
    #     tar xvzf xclip-${XCLIP_VERSION}.tar.gz
    #     cd xclip-${XCLIP_VERSION}
    #     ./configure --prefix=$HOME/.local --disable-shared
    #     make || exit $?
    #     make install || exit $?
    #     cd $TMP_DIR
    #     rm -rf $HOME/.local/src/xclip-*
    #     mv xclip-${XCLIP_VERSION} $HOME/.local/src
    # else
    #     if [[ $platform == "OSX" ]]; then
    #         :
    #     elif [[ $platform == "LINUX" ]]; then
    #         sudo apt-get -y install xclip
    #     fi
    # fi
    # ) >&3 2>&4 \
    #     && echo -e "\033[2K \033[100D${marker_ok} X11 clipboard(xclip / pbcopy / pbpaste) is installed [$1]" \
    #     || echo -e "\033[2K \033[100D${marker_err} X11 clipboard(xclip / pbcopy / pbpaste) install is failed [$1]. use VERBOSE=YES for error message" &
    # [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing X11 clipboard(xclip / pbcopy / pbpaste)..."
}


main() {
    echo
    if [ -x "$(command -v nvim)" ]; then
        echo "${marker_info} Following list is nvim installed on the system"
        coms=($(which -a nvim | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} --version | head -1)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_info} nvim is not found"
    fi
    echo "${marker_info} Local install version (latest version: $NVIM_LATEST_VERSION, installing version: $NVIM_VERSION)"

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_nvim_install} == "yes" ]]; then
            [[ ${CONFIG_nvim_local} == "yes" ]] && setup_func_neovim 'local' || setup_func_neovim 'system'
        else
            echo "${marker_ok} neovim is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install neovim? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install neovim"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install neovim ${NVIM_VERSION} locally"; setup_func_neovim 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install latest neovim systemwide"; setup_func_neovim 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

    [[ ${VERBOSE} == YES ]] || start_spinner "Installing neovim with python support..."
    # install neovim with python support
    (
    pip install virtualenv --user
    pip install virtualenvwrapper --user
    pip3 install virtualenv --user
    pip3 install virtualenvwrapper --user

    rm -rf ${HOME}/.virtualenvs/neovim2 || true
    rm -rf ${HOME}/.virtualenvs/neovim3 || true

    if [[ $platform == "OSX" ]]; then
        source ${HOME}/Library/Python/3.7/bin/virtualenvwrapper.sh
    elif [[ $platform == "LINUX" ]]; then
        source ${HOME}/.local/bin/virtualenvwrapper.sh
    fi

    VIRENV_NAME=neovim2
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=$(which python2)
    mkvirtualenv -p `which python2` ${VIRENV_NAME} || true
    pip install neovim

    VIRENV_NAME=neovim3
    export VIRTUALENVWRAPPER_PYTHON=$(which python3)
    mkvirtualenv -p `which python3` ${VIRENV_NAME} || true
    pip install neovim

    # if [[ $1 = local ]]; then
    #     pip install --no-cache-dir --upgrade --force-reinstall --user neovim || true
    #     pip2 install --no-cache-dir --upgrade --force-reinstall --user neovim || true
    #     pip3 install --no-cache-dir --upgrade --force-reinstall --user neovim || true
    # else
    #     pip install --no-cache-dir --upgrade --force-reinstall neovim || true
    #     pip2 install --no-cache-dir --upgrade --force-reinstall neovim || true
    #     pip3 install --no-cache-dir --upgrade --force-reinstall neovim || true
    # fi
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "neovim with python support is installed" \
        "neovim with python support install is failed. use VERBOSE=YES for error message"

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}

main "$@"
