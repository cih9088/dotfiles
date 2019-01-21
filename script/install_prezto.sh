#!/usr/bin/env zsh
# Original URL of prezto
# htts://github.com/sorin-ionescu/prezto

. ${PROJ_HOME}/script/spinner/spinner.sh

[[ ! -z ${CONFIG+x} ]] && eval $(${PROJ_HOME}/script/parser_yaml ${CONFIG} "CONFIG_")
[[ "${VERBOSE:=NO}" == "YES" ]] && exec 3>&1 4>&2 || exec 3>/dev/null 4>/dev/null
################################################################

setup_func() {
    if [ -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
        rm -rf "${ZDOTDIR:-$HOME}/.zprezto"
        echo "[0;93m[+][0m It seems that prezto was installed before. Uninstall it and reinstall"
    fi
    [[ ${VERBOSE} == YES ]] || start_spinner "Installing prezto..."
    (
    # Clone prezto the repository
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

    # Create a new zsh configureation by copying the zsh config files
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
        ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" || true
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
    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "prezto is installed" \
        "prezto install is failed. use VERBOSE=YES for error message"
}

echo
if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_prezto_install} == "yes" ]]; then
        setup_func
    else
        echo "[0;92m[!][0m prezto is not installed"
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
