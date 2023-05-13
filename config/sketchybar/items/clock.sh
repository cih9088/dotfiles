#!/usr/bin/env bash

clock=(
  update_freq=10
  icon=
  icon.padding_left=10
  label.padding_right=10
  background.color=0xff79A6CB
  background.corner_radius=5
  background.border_color=0xffffffff
  background.border_width=2
  background.height=25
  script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right    \
           --set clock "${clock[@]}"
