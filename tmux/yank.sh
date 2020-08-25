#!/usr/bin/env bash
# Copied from https://github.com/samoshkin/tmux-config
# Modified by Andy <cih9088@gmail.com>


set -eu

is_app_installed() {
  type "$1" &>/dev/null
}

copy_backend_remote_tunnel_port=$(tmux show-option -gvq "@copy_backend_remote_tunnel_port")

# get data either form stdin or from file
buf=$(cat "$@") 

# try osc52 first
if is_app_installed osc52; then
    printf "%s" "$buf" | osc52
fi

# fallback to X11 solutions
if is_app_installed pbcopy; then
    # OSX
    copy_backend="pbcopy"
elif is_app_installed reattach-to-user-namespace; then
    # OSX
    copy_backend="reattach-to-user-namespace pbcopy"
elif [ -n "${DISPLAY-}" ] && is_app_installed xsel; then
    # Linux
    copy_backend="xsel -i --clipboard"
elif [ -n "${DISPLAY-}" ] && is_app_installed xclip; then
    # Linux
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
