#!/usr/bin/env bash
# Copied from https://github.com/samoshkin/tmux-config
# Modified by Inhyuk Andy Cho <cih9088@gmail.com>


set -eu

is_app_installed() {
  type "$1" &>/dev/null
}

copy_backend_remote_tunnel_port=$(tmux show-option -gvq "@copy_backend_remote_tunnel_port")
copy_backend=""

# get data either form stdin or from file
buf=$(cat "$@") 

# update environment variable
eval "$(tmux show-env -s)"

# try osc52 first
osc52_failed=false
if is_app_installed osc52; then
  printf "%s" "$buf" | osc52 || osc52_failed=true
fi

if [ "$osc52_failed" = "true" ]; then
  # fallback to other solutions
  if is_app_installed pbcopy; then
    # OSX
    copy_backend="pbcopy"
  elif is_app_installed reattach-to-user-namespace; then
    # OSX
    copy_backend="reattach-to-user-namespace pbcopy"
  elif [ -n "${DISPLAY-}" ] && is_app_installed xsel; then
    # Linux X11 solution
    copy_backend="xsel -i --clipboard"
  elif [ -n "${DISPLAY-}" ] && is_app_installed xclip; then
    # Linux X11 solution
    copy_backend="xclip -i -f -selection primary | xclip -i -selection clipboard"
  elif is_app_installed clip.exe; then
    # Windows
    copy_backend="clip.exe"
  # fallback to ssh tunnel
  elif [ -n "${copy_backend_remote_tunnel_port-}" ] \
      && (netstat -f inet -nl 2>/dev/null || netstat -4 -nl 2>/dev/null) \
      | grep -q "[.:]$copy_backend_remote_tunnel_port"; then
    copy_backend="nc localhost $copy_backend_remote_tunnel_port"
  fi

  # if copy backend is resolved, copy and exit
  if [ -n "$copy_backend" ]; then
    printf "%s" "$buf" | eval "$copy_backend"
  fi
fi
