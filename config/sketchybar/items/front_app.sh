#!/usr/bin/env bash

front_app=(
  icon.drawing=on
  icon.padding_left=10
  icon.font="$FONT:Heavy:12.0"
  label.padding_right=20
  label.font="$FONT:Regular:12.0"
  associated_display=active
  background.color=0xffE5B370
  background.border_color=0xffffffff
  background.border_width=2
  background.corner_radius=5
  background.height=25
  script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add event window_title_changed         \
           --add item front_app center              \
           --set front_app "${front_app[@]}"        \
           --subscribe front_app front_app_switched window_title_changed
