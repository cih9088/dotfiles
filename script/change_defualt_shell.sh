#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
TARGET_SHELL=""

log_title "Prepare to apply ${THIS_HL}"
################################################################

local_change() {
  local SHELL_FULL_PATH="${HOME}/.local/bin/$1"

  case "$SHELL" in
    *bash) loginshell_rc="$HOME/.bashrc" ;;
    *zsh)  loginshell_rc="$HOME/.zshrc" ;;
    *fish) loginshell_rc="$HOME/.config/fish/config.fish" ;;
    # *csh)  loginshell_rc="$HOME/.cshrc" ;;
    # *tcsh) loginshell_rc="$HOME/.tcshrc" ;;
    # *dash) loginshell_rc="$HOME/.profile" ;;
    *)     log_error "$SHELL is not supported"; exit 1; ;;
  esac

  # sed -i -e '/'$(echo $SHELL_FULL_PATH | sed 's/\//\\\//g')' ]]; then/,/fi/d' ${HOME}/${loginshell_rc}
  for f in ".bashrc" ".zshrc" ".cshrc" ".tcshrc" ".config/fish/config.fish" ".profile"; do
    sed -i -e '/# added from andys dotfiles/,/^fi$/d' $HOME/$f 2>/dev/null || true
  done

  if [ ${SHELL##*/} = ${SHELL_FULL_PATH##*/} ]; then
    log_info "Your default shell is ${SHELL}. No need to change"
    return 0
  fi

  shell=${SHELL##*/}

  if [[ -e ${SHELL_FULL_PATH} ]]; then
    echo -e "# added from andys dotfiles" >> ${loginshell_rc}
    case $shell in
      bash|zsh)
        # echo -e "if [[ -e ${SHELL_FULL_PATH} ]]; then\n\texec ${SHELL_FULL_PATH} -l\nfi" >> ${loginshell_rc}
        echo -e "if [ -e ${SHELL_FULL_PATH} ]; then\n\texec env -u PATH ${SHELL_FULL_PATH} -l\nfi" >> ${loginshell_rc}
        ;;
      fish)
        echo -e "if test -e ${SHELL_FULL_PATH}\n\texec env -u PATH ${SHELL_FULL_PATH} -l\nend" >> ${loginshell_rc}
        ;;
      # csh|tcsh)
      #     echo -e "if ( -e ${SHELL_FULL_PATH} ) then\n\texec env -u PATH ${SHELL_FULL_PATH} -l\nendif" >> ${loginshell_rc}
      #     ;;
      *) :; ;;
    esac
  else
    log_error "${SHELL_FULL_PATH} does not exist"
    return 1
  fi
}

system_change() {
  local SHELL_FULL_PATH=$1
  if [[ ${PLATFORM} == "OSX" ]]; then
    SHELL_FULL_PATH="$(brew --prefix)/bin/${SHELL_FULL_PATH}"
  elif [[ ${PLATFORM} == "LINUX" ]]; then
    SHELL_FULL_PATH="/usr/bin/${SHELL_FULL_PATH}"
  fi

  if [[ ! -s ${SHELL_FULL_PATH} ]]; then
    echo "${SHELL_FULL_PATH} is not a proper shell" >&2
    exit 1
  fi

  grep -q ${SHELL_FULL_PATH} /etc/shells || \
    echo ${SHELL_FULL_PATH} | sudo tee -a /etc/shells >/dev/null

  chsh -s "${SHELL_FULL_PATH}" || exit $?
}

main() {
  if [[ ! -z ${CONFIG+x} ]]; then
    if [[ ${CONFIG_change_default_shell_change} == "true" ]]; then
      if [[ ${CONFIG_change_default_shell_local} == "true" ]]; then
        local_change ${CONFIG_change_default_shell_shell} &&
          log_ok "Changed default shell to local ${CONFIG_change_default_shell_shell}." ||
          log_error "Change default shell to local ${CONFIG_change_default_shell_shell} is failed."
      elif [[ ${CONFIG_change_default_shell_local} == "false" ]]; then
        system_change ${CONFIG_change_default_shell_shell} &&
          log_ok "Changed default shell to systemwide ${CONFIG_change_default_shell_shell}." ||
          log_error "Change default shell to system ${CONFIG_change_default_shell_shell} is failed."
      fi
    else
      log_ok "Default shell is unchanged"
    fi
  else
    while true; do
      yn=$(log_question "Do you want to change default shell? [y/n]")
      case $yn in
        [Yy]* ) :; ;;
        [Nn]* ) log_ok "Default shell is unchanged"; break;;
        * ) log_error "Please answer yes or no"; continue;;
      esac

      yn=$(log_question "Which shell? [zsh/fish]")
      case $yn in
        zsh ) TARGET_SHELL="zsh"; ;;
        fish ) TARGET_SHELL="fish"; ;;
        * ) log_error "Please answer zsh or fish"; continue;;
      esac

      yn=$(log_question "Change default shell to local ${TARGET_SHELL} or systemwide ${TARGET_SHELL}? [local/system]")
      case $yn in
        [Ll]ocal* ) 
          local_change ${TARGET_SHELL} &&
            log_ok "Changed default shell to local ${TARGET_SHELL}." ||
            log_error "Change default shell to local ${TARGET_SHELL} is failed."
          break;;
        [Ss]ystem* )
          system_change ${TARGET_SHELL} &&
            log_ok "Changed default shell to systemwide ${TARGET_SHELL}." ||
            log_error "Change default shell to systemwide ${TARGET_SHELL} is failed."
          break;;
        * ) log_error "Please answer locally or systemwide";;
      esac
    done
  fi
}

main "$@"
