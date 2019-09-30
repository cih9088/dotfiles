#!/usr/bin/env bash

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

NVIM_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release neovim/neovim)"
NVIM_VERSION=${1:-${NVIM_LATEST_VERSION}}
if [[ ${NVIM_VERSION} != 'nightly' ]] && [[ ${NVIM_VERSION} != "v"* ]]; then
    NVIM_VERSION="v${NVIM_VERSION}"
fi

XCLIP_VERSION=0.12

################################################################


setup_func_neovim() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing neovim..."
    (
    if [[ $1 = local ]]; then
        curl -s --head https://github.com/neovim/neovim/releases/tag/${NVIM_VERSION} | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
        if [[ $? != 0 ]]; then
            printf "\033[2K\033[${ctr}D${IRed}[!]${Color_Off} ${NVIM_VERSION} is not a valid version\n" >&2
            printf "\033[2K\033[${ctr}D${IRed}[!]${Color_Off} please visit https://github.com/neovim/neovim/tags for valid versions\n" >&2
            exit 1
        fi

        cd $TMP_DIR
        rm -rf ${HOME}/.local/bin/nvim || true
        rm -rf ${HOME}/.local/man/man1/nvim.1 || true
        rm -rf ${HOME}/.local/share/nvim/runtim || true
        if [[ $platform == "OSX" ]]; then
            if [[ ${NVIM_VERSION} == 'nightly' ]]; then
                wget https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
            else
                wget https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-macos.tar.gz
            fi
            tar -xvzf nvim-macos.tar.gz
            yes | \cp -rf nvim-osx64/* $HOME/.local/
        elif [[ $platform == "LINUX" ]]; then

            if ! [  -x "$(command -v pyenv)" ]; then
                curl https://pyenv.run | bash
                rm -rf ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper || true
                git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper
            fi

            if [[ ${NVIM_VERSION} == 'nightly' ]]; then
                wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
            else
                wget https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage
            fi
            # https://github.com/neovim/neovim/issues/7620
            # https://github.com/neovim/neovim/issues/7537
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
            brew install pyenv
            brew install neovim
            brew install pyenv-virtualenv
            brew install pyenv-virtualenvwrapper
        elif [[ $platform == "LINUX" ]]; then

            if ! [  -x "$(command -v pyenv)" ]; then
                curl https://pyenv.run | bash
                rm -rf ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper || true
                git clone https://github.com/pyenv/pyenv-virtualenvwrapper.git ${HOME}/.pyenv/plugins/pyenv-virtualenvwrapper
            fi

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
    pyenv install -s 3.7.2
    pyenv install -s 2.7.16
    #pip install virtualenv --user
    #pip install virtualenvwrapper --user
    pip3 install virtualenv --user
    #pip3 install virtualenvwrapper --user

    export WORKON_HOME=${HOME}/.virtualenvs

    rm -rf ${WORKON_HOME}/neovim2 || true
    rm -rf ${WORKON_HOME}/neovim3 || true

    VIRENV_NAME=neovim2
    virtualenv --python=$(${HOME}/.pyenv/versions/2.7.16) ${WORKON_HOME}/${VIRENV_NAME}
    source ${WORKON_HOME}/neovim2/bin/activate
    pip install neovim

    VIRENV_NAME=neovim3
    virtualenv --python=$(${HOME}/.pyenv/versions/3.7.2) ${WORKON_HOME}/${VIRENV_NAME}
    source ${WORKON_HOME}/neovim3/bin/activate
    pip install neovim

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
