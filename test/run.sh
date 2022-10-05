#!/usr/bin/env bash

set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

COMMAND="${1:-docker}"

ITEMS=(
  cmake zlib bzip2 unzip gzip xz
  "zsh prezto" "neovim" "tmux tpm tmux-plugins"
  tree fd rg thefuck tldr bash-snippets up jq sox tcpdump
  "pyenv python" "goenv golang" "asdf python golang rust nodejs lua"
)


for item in "${ITEMS[@]}"; do
  item=(${item})

  echo "rockylinux local ${item[*]}  ++++++++++++++++++++++++++++++"
  ${COMMAND} run -it --rm \
    -v "$DIR"/..:/root/dotfiles:z \
    rockylinux:dot \
    bash -c "/root/dotfiles/bin/dots --verbose -y -m local install ${item[*]} &&
    /root/dotfiles/bin/dots --verbose -y -m local remove ${item[*]}"

  echo "ubuntu local ${item[*]}  ++++++++++++++++++++++++++++++"
  ${COMMAND} run -it --rm \
    -v "$DIR"/..:/root/dotfiles:z \
    ubuntu:dot \
    bash -c "/root/dotfiles/bin/dots --verbose -y -m local install ${item[*]} &&
    /root/dotfiles/bin/dots --verbose -y -m local remove ${item[*]}"

  echo "rockylinux system ${item[*]}  ++++++++++++++++++++++++++++++"
  ${COMMAND} run -it --rm \
    -v "$DIR"/..:/root/dotfiles:z \
    rockylinux:dot \
    bash -c "/root/dotfiles/bin/dots --verbose -y -m system install ${item[*]} &&
    /root/dotfiles/bin/dots --verbose -y -m system remove ${item[*]}"

  echo "ubuntu system ${item[*]}  ++++++++++++++++++++++++++++++"
  ${COMMAND} run -it --rm \
    -v "$DIR"/..:/root/dotfiles:z \
    ubuntu:dot \
    bash -c "/root/dotfiles/bin/dots --verbose -y -m system install ${item[*]} &&
    /root/dotfiles/bin/dots --verbose -y -m system remove ${item[*]}"

done
