#!/bin/zsh
# Original URL of prezto
# htts://github.com/sorin-ionescu/prezto

spinner() {
    local info="$1"
    local pid="$!"
    local delay=0.75
    local spinstr='|/-\'
    local ctr=0
    for (( i = 1; i <= $(printf "$info  [%c] " "$spinstr" | expand | wc -m ); i++ )); do
        local ctr=$(( $ctr + 1 ))
    done
    while kill -0 $pid 2> /dev/null; do
        local temp=${spinstr#?}
        printf "$info  [%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\033[2K \033[${ctr}D"
    done
}
[[ ! -z ${CONFIG+x} ]] && eval $(${PROJ_HOME}/script/parser_yaml ${CONFIG} "CONFIG_")
################################################################

setup_func() {
    if [ -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
        echo "[0;93m[+][0m prezto is installed. No need to install. Abort"
    else
        (
        # Clone prezto the repository
        #git clone --recursive https://github.com/cih9088/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

        # Create a new zsh configureation by copying the zsh config files
        setopt EXTENDED_GLOB
        for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
            ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
        done

        ## Clone garrett prompt repository
        #git clone https://github.com/cih9088/zsh-prompt-garrett.git ./prompt
        #
        #cd prompt
        #cp prompt_garrett_setup ~/.zprezto/modules/prompt/functions/
        #cd ..
        #rm -rf prompt
        #


        # adding vi-mode indicator https://github.com/sindresorhus/pure/wiki
        # this feature is in the master. no need.
        # if grep -Fq 'PROMPT+='\''%(?.%F{magenta}.%F{red})${editor_info[keymap]} '\' "$HOME/.zprezto/modules/prompt/functions/prompt_pure_setup"; then
        #     :
        # else
        #     sed -i -e '457s/^/#/' "$HOME/.zprezto/modules/prompt/functions/prompt_pure_setup"
        #     sed -i -e '458s/^/\'$'\n''	zstyle '\'':prezto:module:editor:info:keymap:primary'\''   format '\"'❯%f'\"'\'$'\n''	zstyle '\'':prezto:module:editor:info:keymap:alternate'\''   format '\"'❮%f'\"'\'$'\n''	PROMPT+='\''%(?.%F{magenta}.%F{red})${editor_info[keymap]} '\''\'$'\n/' "$HOME/.zprezto/modules/prompt/functions/prompt_pure_setup"
        # fi
        ) &> /dev/null &
        [[ ${VERBOSE} == YES ]] && wait || spinner "[0;93m[+][0m Installing prezto..."
        echo "[0;92m[*][0m prezto installed"

    fi
}

echo
if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_prezto_install} == "yes" ]]; then
        setup_func
    else
        echo "[0;91m[!][0m prezto is not installed"
    fi
else
    while true; do
        read "yn?[0;96m[?][0m Do you wish to install prezto? "
        # vared -p "Do you wish to install prezto? " -c yn
        case $yn in
            [Yy]* ) echo "[0;93m[+][0m Install prezto"; setup_func; break;;
            [Nn]* ) echo "[0;91m[!][0m Aborting install prezto"; break;;
            * ) echo "[0;91m[!][0mPlease answer yes or no";;
        esac
    done
fi
