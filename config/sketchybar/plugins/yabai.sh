#!/usr/bin/env bash


space_layout() {
  layout="$(yabai -m query --spaces --space | jq -r '.type')"

  args=()
  if [ "$layout" == "bsp" ]; then
    args+=(--set yabai label="舘" label.align=center label.drawing=on)
  elif [ "$layout" == "stack" ]; then
    args+=(--set yabai label="" label.align=center label.drawing=on)
  elif [ "$layout" == "float" ]; then
    args+=(--set yabai label="恵" label.align=center label.drawing=on)
  fi

  sketchybar -m "${args[@]}"
}

windows_on_spaces () {
  CURRENT_SPACES="${1:-$(yabai -m query --displays | jq -r '.[].spaces | @sh')}"
  source $CONFIG_DIR/plugins/icon_map_fn.sh

  args=()

  while read -r line
  do
    for space in $line
    do
      icon_strip=""
      apps=$(yabai -m query --windows --space $space | jq -r ".[].app")
      if [ "$apps" != "" ]; then
        while IFS= read -r app; do
          icon_map "$app"
          icon_strip+="${icon_result}  "
        done <<< "$apps"
      fi
      if [ ! -z "${icon_strip}" ]; then
        args+=(--set space.$space label="$icon_strip" label.drawing=on)
      else
        args+=(--set space.$space label.drawing=off)
      fi
    done
  done <<< "$CURRENT_SPACES"

  sketchybar -m "${args[@]}"
}

space_layout_change() {
  yabai -m space --layout \
    "$(yabai -m query --spaces --space | 
    jq -r 'if .type == "bsp" then "float"
           elif .type == "float" then "stack"
           elif .type == "stack" then "bsp"
           else empty end')"
}

mouse_entered() {
  sketchybar --set $NAME background.drawing=on
}

mouse_exited() {
  sketchybar --set $NAME background.drawing=off
}

case "$SENDER" in
  "mouse.clicked")
    space_layout_change
    space_layout
    ;;
  "mouse.entered")
    mouse_entered
    ;;
  "mouse.exited")
    mouse_exited
    ;;
  "layout_change" )
    space_layout
    ;;
  "window_focused" )
    windows_on_spaces $(yabai -m query --spaces --space recent | jq -r '.index')
    windows_on_spaces $(yabai -m query --spaces --space | jq -r '.index')
    # windows_on_spaces
    ;;
  "space_changed" )
    space_layout
    ;;
  "system_woke" )
    space_layout
    windows_on_spaces
    ;;
esac
