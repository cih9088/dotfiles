#!/usr/bin/env bash

set -eu


ITEMS=(
  "zsh prezto" "neovim" "tmux tpm tmux-plugins" tree fd rg thefuck tldr bash-snippets up fq sox
  pyenv goenv "asdf python golang rust nodejs lua sh"
)

# ITEMS=(
#   "custom-bins configs zsh prezto asdf python golang rust nodejs lua sh neovim neovim-plugins tmux tpm tmux-plugins tree fd rg thefuck tldr bash-snippets up jq sox"
# )


for item in "${ITEMS[@]}"; do
  echo '============================'
  item=(${item})

  echo 'rockylinux system   ----------------------------'
  podman run -it --rm \
    -v /home/andy/dotfiles:/root/dotfiles:z \
    rockylinux:dot \
    bash -c "/root/dotfiles/bin/dots -y -m system install ${item[@]} &&
    /root/dotfiles/bin/dots -y -m system update ${item[@]} &&
    /root/dotfiles/bin/dots -y -m system remove ${item[@]}"

  # echo 'ubuntu system   ----------------------------'
  # podman run -it --rm \
  #   -v /home/andy/dotfiles:/root/dotfiles:z \
  #   ubuntu:dot \
  #   bash -c "/root/dotfiles/bin/dots -y -m system install ${item[@]} &&
  #   /root/dotfiles/bin/dots -y -m system update ${item[@]} &&
  #   /root/dotfiles/bin/dots -y -m system remove ${item[@]}"

  # echo 'rockylinux local   ----------------------------'
  # podman run -it --rm \
  #   -v /home/andy/dotfiles:/root/dotfiles:z \
  #   rockylinux:dot \
  #   bash -c "/root/dotfiles/bin/dots -y -m local install ${item[@]} &&
  #   /root/dotfiles/bin/dots -y -m local update ${item[@]} &&
  #   /root/dotfiles/bin/dots -y -m local remove ${item[@]}"

  # podman run -it --rm \
  #   -v /home/andy/dotfiles:/root/dotfiles:z \
  #   ubuntu:dot \
  #   bash -c "/root/dotfiles/bin/dots -y -m system install ${item[@]} &&
  #   /root/dotfiles/bin/dots -y -m system update ${item[@]} &&
  #   /root/dotfiles/bin/dots -y -m system remove ${item[@]}"
  echo '============================'
done

