#!/usr/bin/env bash

wifi=(
  icon=
  label.padding_right=10
  icon.padding_left=10
  script="$PLUGIN_DIR/wifi.sh"
)

wifi_bracket=(
  background.color=0xff83A098
  background.corner_radius=5
  background.border_color=0xffffffff
  background.border_width=2
  background.height=25
)

sketchybar --add item padding_wifi right           \
           --set padding_wifi "${padding[@]}"      \
           --add item wifi right                   \
           --set wifi "${wifi[@]}"                 \
           --subscribe wifi wifi_change            \
           --add bracket wifi_bracket wifi         \
           --set wifi_bracket "${wifi_bracket[@]}"
