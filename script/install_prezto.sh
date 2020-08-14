#!/usr/bin/env zsh
# Original URL of prezto
# htts://github.com/sorin-ionescu/prezto

. ${PROJ_HOME}/script/spinner/spinner.sh

[[ ! -z ${CONFIG+x} ]] && eval $(${PROJ_HOME}/script/parser_yaml ${CONFIG} "CONFIG_")
[[ "${VERBOSE:=false}" == "true" ]] && exec 3>&1 4>&2 || exec 3>/dev/null 4>/dev/null

echo
echo "[0;93m[+][0m Prepare to install prezto"
################################################################

setup_func() {
    if [ -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
        rm -rf "${ZDOTDIR:-$HOME}/.zprezto"
        echo "[0;93m[+][0m It seems that prezto was installed before. Uninstall and reinstall it"
    fi
    [[ ${VERBOSE} == "true" ]] \
        && echo "[0;93m[+][0m Installing prezto..." \
        || start_spinner "Installing prezto..."
    (
    # Clone prezto the repository
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    # Clone prezto-contrib repository
    git clone --recurse-submodules https://github.com/belak/prezto-contrib "${ZDOTDIR:-$HOME}/.zprezto/contrib"

    # Create a new zsh configureation by copying the zsh config files
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
        ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" || true
    done

    # pure prompt update
    cd ${HOME}/.zprezto/modules/prompt/external/pure
    git checkout master
    git pull

    ## Clone garrett prompt repository
    #git clone https://github.com/cih9088/zsh-prompt-garrett.git ./prompt
    #
    #cd prompt
    #cp prompt_garrett_setup ~/.zprezto/modules/prompt/functions/
    #cd ..
    #rm -rf prompt
    #

    ) >&3 2>&4 || exit_code="$?" && true
    stop_spinner "${exit_code}" \
        "prezto is installed" \
        "prezto install is failed. use VERBOSE=true for error message"
}

if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_prezto_install} == "true" ]]; then
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
