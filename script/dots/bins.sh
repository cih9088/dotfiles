#!/usr/bin/env bash

################################################################
THIS=$(basename "$0")
THIS=${THIS%.*}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. ${DIR}/../helpers/common.sh
################################################################

THIS_HL=${BOLD}${UNDERLINE}${THIS}${NC}

log_title "Prepare for ${THIS_HL}"
################################################################

setup_for_local() {
  local COMMAND="${1:-skip}"

  # remove broken symlink
  for file in $(find -L ${PREFIX}/bin -type l); do
    log_info "Remove broken symbolic link '$file'"
    rm -rf ${file}
  done

  if [ "${COMMAND}" == "remove" ]; then
    for file in `find ${PREFIX}/bin -type l -lname "$PROJ_HOME*"`; do
      log_info "Remove symbolic link '$file'"
      rm -rf ${file}
    done
  elif [[ "install update"  == *"${COMMAND}"* ]]; then
    case ${PLATFORM} in
      OSX )
        # install
        for file in `find ${BIN_DIR} -mindepth 1 -perm +111 -exec basename {} \;`; do
          log_info "Update symbolic link '${BIN_DIR}/${file}' -> '${PREFIX}/bin/$file'"
          ln -snf ${BIN_DIR}/${file} ${PREFIX}/bin/$file
        done
        ;;
      LINUX )
        for file in `find ${BIN_DIR} -mindepth 1 -executable -printf "%f\n"`; do
          log_info "Update symbolic link '${BIN_DIR}/${file}' -> '${PREFIX}/bin/$file'"
          ln -snf ${BIN_DIR}/${file} ${PREFIX}/bin/$file
        done
        ;;
    esac
  fi
}

main_script "${THIS}" \
  setup_for_local ""
