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
            wget https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz
            tar -xvJf shellcheck-stable.linux.x86_64.tar.xz
            cd shellcheck-stable
            cp shellcheck $HOME/.local/bin
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
    ) >&3 2>&4 &
    spinner "${marker_info} Installing shellcheck..."
    echo "${marker_ok} shellcheck installed"
}

main() {
    echo
    if [ -x "$(command -v shellchecker)" ]; then
        echo "${marker_info} Following list is shellchecker insalled on the system"
        coms=($(which -a shellchecker | uniq))
        (
            printf 'LOCATION,VERSION\n'
            for com in "${coms[@]}"; do
                printf '%s,%s\n' "${com}" "$(${com} -version | head -2 | tail -1)"
            done
        ) | column -t -s ',' | sed 's/^/    /'
    else
        echo "${marker_err} shellchecker is not found"
    fi

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
            [Ss]ystem* ) echo "${marker_info} Install shellcheck systemwide"; setup_func_shellcheck; break;;
            * ) echo "${marker_err} Please answer locally or systemwide"; continue;;
        esac
    done
}

main "$@"
