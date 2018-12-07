#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/common.sh
################################################################


setup_func_shellcheck() {
    (
    if [[ $1 = local ]]; then
        cd $TMP_DIR
        if [[ $platform == "OSX" ]]; then
            echo "${marker_err} Not available on OSX"
            exit 1
        elif [[ $platform == "LINUX" ]]; then
            rm -rf $HOME/.local/bin/shellcheck || true
            wget https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz
            tar -xvJf shellcheck-stable.linux.x86_64.tar.xz
            cd shellcheck-stable
            yes | \cp -rf shellcheck $HOME/.local/bin
        fi
    else
        if [[ $platform == "OSX" ]]; then
            # brew install shellcheck
            brew bundle --file=- <<EOS
brew 'shellcheck'
EOS
        elif [[ $platform == "LINUX" ]]; then
            sudo apt-get install shellcheck
        fi
    fi
    ) >&3 2>&4 \
        && echo -e "\033[2K \033[100D${marker_ok} shellcheck is installed [$1]" \
        || echo -e "\033[2K \033[100D${marker_err} shellcheck install is failed [$1]. use VERBOSE=YES for error message" &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing shellcheck..."

}

setup_func_bash_language_server() {
    (npm i -g bash-language-server) >&3 2>&4 \
        && echo -e "\033[2K \033[100D${marker_ok} bash-language-server is installed [local]" \
        || echo -e "\033[2K \033[100D${marker_err} bash-language-server install is failed [local]. use VERBOSE=YES for error message" &
    [[ ${VERBOSE} == YES ]] && wait || spinner "${marker_info} Installing bash-language-server..."
}

main() {
    echo
    if [ -x "$(command -v shellchecker)" ]; then
        echo "${marker_info} Following list is shellchecker installed on the system"
        coms=($(which -a shellchecker | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} -version | head -2 | tail -1)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_info} shellchecker is not found"
    fi

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_shellchecker_install} == "yes" ]]; then
            [[ ${CONFIG_shellchecker_local} == "yes" ]] && setup_func_shellcheck 'local' || setup_func_shellcheck 'system'
        else
            echo "${marker_ok} shellchecker is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install shellcheck? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install shellcheck"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            read -p "${marker_que} Install locally or systemwide? " yn
            case $yn in
                [Ll]ocal* ) echo "${marker_info} Install shellcheck locally"; setup_func_shellcheck 'local'; break;;
                [Ss]ystem* ) echo "${marker_info} Install shellcheck systemwide"; setup_func_shellcheck 'system'; break;;
                * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
            esac
        done
    fi

    echo
    if [ -x "$(command -v bash-language-server)" ]; then
        echo "${marker_info} Following list is bash-language-server installed on the system"
        coms=($(which -a bash-language-server | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} -version | head -2 | tail -1)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_info} bash-language-server is not found"
    fi

    if [[ ! -z ${CONFIG+x} ]]; then
        if [[ ${CONFIG_bash_language_server_install} == "yes" ]]; then
            setup_func_bash_language_server
        else
            echo "${marker_ok} bash_language_server is not installed"
        fi
    else
        while true; do
            read -p "${marker_que} Do you wish to install bash-language-server? " yn
            case $yn in
                [Yy]* ) :; ;;
                [Nn]* ) echo "${marker_err} Aborting install bash-language-server"; break;;
                * ) echo "${marker_err} Please answer yes or no"; continue;;
            esac

            setup_func_bash_language_server
            break
        done
    fi

    # clean up
    if [[ $$ = $BASHPID ]]; then
        rm -rf $TMP_DIR
    fi
}

main "$@"
