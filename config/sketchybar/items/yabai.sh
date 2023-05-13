#!/usr/bin/env bash

yabai=(
  icon.width=0
  label.width=30
  label.padding_left=10
  label.padding_right=10
  label.font.size="15.0"
  background.color=0xff79A6CB
  background.border_color=0xffffffff
  background.border_width=2
  background.corner_radius=5
  background.height=25
  associated_display=active
  script="$PLUGIN_DIR/yabai.sh"
  padding_right=0
)

sketchybar --add event layout_change            \
           --add item yabai left                \
           --set yabai "${yabai[@]}"            \
           --subscribe yabai space_change       \
                             display_change     \
                             mouse.clicked      \
                             mouse.entered      \
                             mouse.exited       \
                             front_app_switched \
                             layout_change
