#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/helpers/common.sh
################################################################

THIS_HL="${BOLD}${UNDERLINE}${THIS}${NC}"
TARGET_SHELL=""

log_title "Prepare for ${THIS_HL}"
################################################################

local_change() {
  local SHELL_FULL_PATH="$1"

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
    f=$(readlink -f $HOME/$f)
    if [ -e $f ]; then
      # -i destroy symlink. --follow-symlink option only in GNU sed
      sed -e '/# added by dots/,/^fi$/d' $f > temp
      mv temp $f
    fi
  done

  if [ ${SHELL##*/} = ${SHELL_FULL_PATH##*/} ]; then
    log_info "Your default shell is ${SHELL}. No need to change."
    return 0
  fi

  shell=${SHELL##*/}

  if [[ -e ${SHELL_FULL_PATH} ]]; then
    echo -e "# added by dots" >> ${loginshell_rc}
    case $shell in
      bash|zsh)
        # echo -e "if [[ -e ${SHELL_FULL_PATH} ]]; then\n\texec ${SHELL_FULL_PATH} -l\nfi" >> ${loginshell_rc}
        echo -e "if [[ \$- == *i* ]] && [[ -e ${SHELL_FULL_PATH} ]]; then\n\texec env -u PATH ${SHELL_FULL_PATH} -l\nfi" >> ${loginshell_rc}
        ;;
      fish)
        echo -e "if status is-interactive -a -e ${SHELL_FULL_PATH}\n\texec env -u PATH ${SHELL_FULL_PATH} -l\nend" >> ${loginshell_rc}
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

  if [[ ! -s ${SHELL_FULL_PATH} ]]; then
    echo "${SHELL_FULL_PATH} is not a proper shell" >&2
    exit 1
  fi

  # grep -q ${SHELL_FULL_PATH} /etc/shells \
  #   || echo ${SHELL_FULL_PATH} | sudo tee -a /etc/shells >/dev/null

  ++ chsh -s "${SHELL_FULL_PATH}"
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
      log_ok "Default shell is unchanged."
    fi
  else
    while true; do
      log_info "Please provide full path. Type shell to list full path of them."
      SHELL_FULL_PATH=$(log_question "Which shell? ")
      if [[ $SHELL_FULL_PATH != *"bash" ]] && [[ $SHELL_FULL_PATH != *"zsh" ]] && [[ $SHELL_FULL_PATH != *"fish" ]]; then
        log_error "Supported shells are bash, zsh, and fish"
        echo
        continue
      fi
      if [ ! -x "$SHELL_FULL_PATH" ]; then
        paths=$(type -aP $SHELL_FULL_PATH || true)
        if [ ${#paths} -ne 0 ]; then
          log_info "List of $SHELL_FULL_PATH"
          echo "$paths"
          echo
        else
          log_error "Wrong command or path $SHELL_FULL_PATH"
          echo
          continue
        fi
      else
        break
      fi
    done

    is_valid_shell=false
    if grep -q '^'$SHELL_FULL_PATH'$' /etc/shells; then
      is_valid_shell=true
    fi

    yn=$(log_question "Change default shell to ${SHELL_FULL_PATH}? [y/n] ")
    case $yn in
      [Yy]* )
        if [ $is_valid_shell == true ]; then
          system_change ${SHELL_FULL_PATH} &&
            log_ok "Changed default shell to ${SHELL_FULL_PATH}." ||
            log_error "Change default shell to ${SHELL_FULL_PATH} is failed."
        else
          local_change ${SHELL_FULL_PATH} &&
            log_ok "Changed default shell to ${SHELL_FULL_PATH}." ||
            log_error "Change default shell to ${SHELL_FULL_PATH} is failed."
        fi
        ;;
      [Nn]* )
        ;;
    esac

  fi
}

main "$@"
