#!/usr/bin/env bash


# git config --global --add safe.directory /home/docker/dotfiles; sudo chown -R docker.docker /home/docker/dotfiles
# /home/docker/dotfiles/bin/dots --yes --verbose --mode system --config /home/docker/dotfiles/config.yaml install
# /home/docker/dotfiles/bin/dots --yes --verbose --mode local --config /home/docker/dotfiles/config.yaml install

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

ERR_CODE_INSTALL=111
ERR_CODE_REMOVE=222

DEFAULT_CMD="docker"
if command -v podman > /dev/null; then
  DEFAULT_CMD="podman"
fi

COMMAND="${COMMAND:-$DEFAULT_CMD}"
N_WORKERS="${N_WORKERS:-$(( $(nproc --all) / 2 ))}"
WORK_DIR=""

[ "${N_WORKERS}" -le 0 ] && N_WORKERS=1

if [ "${N_WORKERS}" -gt 1 ]; then
  WORK_DIR=$(mktemp -d)
fi

FAILED=()

IMAGES=("rockylinux_dots:8" "rockylinux_dots:9" "ubuntu_dots:20" "ubuntu_dots:22")
MODES=("local" "system")
ITEMS=(
  perl "asdf perl"
  "pyenv python" "asdf python python-env"
  "goenv golang" "asdf golang"
  "asdf rust"
  nodejs "asdf nodejs nodejs-env"
  "asdf lua lua-env"
  sh-env

  terminfo cmake zlib bzip2 unzip gzip xz libjpeg-turbo opencv ncurses
  "zsh prezto" neovim "tmux tpm"
  wget tree fd rg thefuck tldr bash-snippets up jq sox pandoc tcpdump

  bin configs
)


open_sem(){
  mkfifo pipe-$$
  exec 3<>pipe-$$
  rm pipe-$$
  local i=$1
  for((;i>0;i--)); do
    printf "%s\n" 0 >&3
  done
}

test_return() {
  local x="$1"
  local exit_code
  local cmd

  exit_code=$(echo "$x" | cut -d ' ' -f 1)
  cmd=$(echo "$x" | cut -d ' ' -f 3-)

  if [ "${exit_code}" != 0 ]; then
    if [ "${exit_code}" = ${ERR_CODE_INSTALL} ]; then
      FAILED+=("INSTALL $cmd")
    elif [ "${exit_code}" = ${ERR_CODE_REMOVE} ]; then
      FAILED+=("REMOVE $cmd")
    else
      FAILED+=("UNKNOWN $cmd")
    fi
  fi
}

run_with_lock(){
  local x

  read -u 3 -r x
  test_return "$x"
  (
  if [ ${N_WORKERS} -gt 1 ]; then
    ( "$@"; )  &>"$WORK_DIR/${image}_${mode}_${items}"
  else
    ( "$@"; )
  fi
  echo "$? $@" >&3
  )&
}

task() {
  local image=$1
  local mode=$2
  local items=$3

  local exit_code=0

  ${COMMAND} run --rm \
    -v "$DIR"/..:/dotfiles:z \
    "${image}" \
    bash -c "\
      sudo cp -r /dotfiles /home/docker/dotfiles &&
      sudo chown -R docker.docker /home/docker/dotfiles &&
      git config --global --add safe.directory /home/docker/dotfiles;
      EXIT_CODE=0;
      /home/docker/dotfiles/bin/dots \
        --verbose --yes --mode ${mode} install ${items[*]} || EXIT_CODE=${ERR_CODE_INSTALL};
      [ \$EXIT_CODE != 0 ] && exit \$EXIT_CODE;
      /home/docker/dotfiles/bin/dots \
        --verbose --yes --mode ${mode} remove $(echo "${items}" | tr " " "\n" | tac | tr "\n" " ") || EXIT_CODE=${ERR_CODE_REMOVE};
      exit \$EXIT_CODE;
      " || exit_code=$?

  return $exit_code
}

# build image
BUILT_IMAGES=$(${DEFAULT_CMD} image ls --format '{{.Repository}}:{{.Tag}}' | sed -e 's/localhost\///' | tr '\n' ' ')
for image in "${IMAGES[@]}"; do
  [[ " $BUILT_IMAGES " = *" ${image} "* ]] || "${DEFAULT_CMD}" build -t "${image}" -f "${DIR}/images/${image/dots:/}.Dockerfile" .
done
unset BUILT_IMAGES

[ -n "${WORK_DIR}" ] && echo "WORK_DIR: ${WORK_DIR}" || true
echo "N_WORKERS: ${N_WORKERS}" || true

N_TOTAL=$(( ${#IMAGES[@]} * ${#ITEMS[@]} * ${#MODES[@]} ))
CTR=1
open_sem "${N_WORKERS}"
for image in "${IMAGES[@]}"; do
  for items in "${ITEMS[@]}"; do
    for mode in "${MODES[@]}"; do
      printf "[%${#N_TOTAL}d/%d] %-30s || %s\n" "$CTR" "$N_TOTAL" "$image - $mode" "$items"
      run_with_lock task "${image}" "${mode}" "${items}"
      CTR=$(( $CTR + 1 ))
    done
  done
done
wait
unset N_TOTAL
unset CTR

for((i=$N_WORKERS;i>0;i--)); do
  read -u 3 -t 1 -r x
  test_return "$x"
done

if [ ${#FAILED[@]} -gt 0 ]; then
  echo
  echo "FAILED"
  for i in "${FAILED[@]}"; do
    echo "$i"
  done
fi
