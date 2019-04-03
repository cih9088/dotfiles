#!/usr/bin/env bash

# change version you want to install on local
LIBEVENT_VERSION=2.1.8
NCURSES_VERSION=6.1
XCLIP_VERSION=0.12

# based on https://gist.github.com/ryin/3106801#gistcomment-2191503
# tmux will be installed in $HOME/.local/bin if you specify to install without root access
# It's assumed that wget and a C/C++ compiler are installed.

################################################################
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################

TMUX_LATEST_VERSION="$(${PROJ_HOME}/script/get_latest_release tmux/tmux)"
TMUX_VERSION=${1:-${TMUX_LATEST_VERSION}}

################################################################


setup_func() {
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing tmux..."
    (
    # install prerequisite
    if [[ $1 = local ]]; then
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
        wget http://invisible-island.net/datafiles/release/ncurses.tar.gz
        tar -xvzf ncurses.tar.gz
        cd ncurses-${NCURSES_VERSION}
        ./configure --prefix=$HOME/.local
        make || exit $?
        make install || exit $?
        cd $TMP_DIR
        mv ncurses-${NCURSES_VERSION} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            brew install libevent ncurses
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get -y remove libevent-dev libncurses-dev
            sudo apt-get -y install libevent-dev libncurses-dev
            sudo apt-get -y remove tmux
        fi
    fi

    # install tmux
    if [[ $1 == local ]]; then

        curl -s --head https://github.com/tmux/tmux/releases/tag/${TMUX_VERSION} | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
        if [[ $? != 0 ]]; then
            printf "\033[2K\033[${ctr}D${IRed}[!]${Color_Off} ${TMUX_VERSION} is not a valid version\n" >&2
            printf "\033[2K\033[${ctr}D${IRed}[!]${Color_Off} please visit https://github.com/tmux/tmux/tags for valid versions\n" >&2
            exit 1
        fi

        if [ -d $HOME/.local/src/tmux-* ]; then
            cd $HOME/.local/src/tmux-*
            make uninstall
            make clean
            cd ..
            rm -rf $HOME/.local/src/tmux-*
        fi
        cd $TMP_DIR

        # install xclip
#         if [[ $platform == "OSX" ]]; then
#             echo 'reattatch-to-user-namespace will be installed using brew that need sudo privileges' >&2
#             brew install reattach-to-user-namespace
#             brew bundle --file=- <<EOS
# brew 'reattach-to-user-namespace'
# EOS
#         elif [[ $platform == "LINUX" ]]; then
#             wget http://kent.dl.sourceforge.net/project/xclip/xclip/${XCLIP_VERSION}/xclip-${XCLIP_VERSION}.tar.gz
#             tar -xvzf xclip-${XCLIP_VERSION}.tar.gz
#             cd xclip-${XCLIP_VERSION}
#             ./configure --prefix=$HOME/.local --disable-shared
#             make || exit $?
#             make install || exit $?
#             cd $TMP_DIR
#             mv xclip-${XCLIP_VERSION} $HOME/.local/src
#         fi

        # install tmux
        wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
        tar -xvzf tmux-${TMUX_VERSION}.tar.gz
        cd tmux-${TMUX_VERSION}
        ./configure CFLAGS="-I$HOME/.local/include -I$HOME/.local/include/ncurses" LDFLAGS="-L$HOME/.local/lib -L$HOME/.local/include/ncurses -L$HOME/.local/include" --prefix=$HOME/.local
        (CPPFLAGS="-I$HOME/.local/include -I$HOME/.local/include/ncurses" LDFLAGS="-static -L$HOME/.local/include -L$HOME/.local/include/ncurses -L$HOME/.local/lib" make)
        make install || exit $?
        mv tmux $HOME/.local/bin
        cd $TMP_DIR
        mv tmux-${TMUX_VERSION} $HOME/.local/src
    else
        if [[ $platform == "OSX" ]]; then
            brew install reattach-to-user-namespace
            brew install tmux

        elif [[ $platform == "LINUX" ]]; then
            if [ -d /usr/local/src/tmux-* ]; then
                cd /usr/local/src/tmux-*
                sudo make uninstall
                cd ..
                sudo rm -rf /usr/local/src/tmux-*
            fi

            cd $TMP_DIR
            # install xclip
            # sudo apt-get -y install xclip

            # install tmux
            wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
            tar -xvzf tmux-${TMUX_VERSION}.tar.gz
            cd tmux-${TMUX_VERSION}
            ./configure
            make || exit $?
            sudo make install || exit $?
            cd $TMP_DIR
            sudo mv tmux-${TMUX_VERSION} /usr/local/src
        fi
    fi
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "tmux is installed [$1]" \
        "tmux install is failed [$1]. use VERBOSE=YES for error message"
}

main() {
    echo
    if [ -x "$(command -v tmux)" ]; then
        echo "${marker_info} Following list is tmux installed on the system"
        coms=($(which -a tmux | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} -V)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_info} tmux is not found"
    fi
    echo "${marker_info} Local install version (latest version: $TMUX_LATEST_VERSION, installing version: $TMUX_VERSION)"

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_tmux_install} == "yes" ]]; then
            [[ ${CONFIG_tmux_local} == "yes" ]] && setup_func 'local' || setup_func 'system'
        else
            echo "${marker_ok} tmux is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install tmux? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install tmux"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or sytemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install tmux ${TMUX_VERSION} locally"; setup_func 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install latest tmux systemwide"; setup_func 'system'; break;;
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
