#!/usr/bin/env bash

set -eu

pane_fmt="#{pane_id} #{pane_in_mode} #{pane_input_off} #{pane_dead} #{pane_current_command}"
tmux list-panes -s -F "$pane_fmt" | awk '
  $2 == 0 && $3 == 0 && $4 == 0 && $5 ~ /(bash|zsh|ksh|fish)/ { print $1 }
' | while read -r pane_id; do

  # renew environment variables according to update-environment tmux option
  _CMD=' eval "$(tmux show-env -s)"; '

  # renew ls color
  [ -f $DOTS/config/zsh/ls_colors/ls_colors.$COLOUR_SCHEME ] &&
    _CMD+='export LS_COLORS="$(cat $DOTS/config/zsh/ls_colors/ls_colors.$COLOUR_SCHEME)"; ' ||
    _CMD+='export LS_COLORS="$(cat $DOTS/config/zsh/ls_colors/ls_colors.$BG_LUMINANCE)"; '

  # renew fzf color
  [ -f $DOTS/config/zsh/fzf_colors/fzf.$COLOUR_SCHEME ] &&
    _CMD+='export FZF_DEFAULT_OPTS="$(cat $DOTS/config/zsh/fzf_colors/fzf.$COLOUR_SCHEME)"; ' ||
    _CMD+='export FZF_DEFAULT_OPTS="$(cat $DOTS/config/zsh/fzf_colors/fzf.$BG_LUMINANCE)"; '

  # Execute
  tmux send-keys -t "$pane_id" 'Enter' "$_CMD" 'Enter'
done;
