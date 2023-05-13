#!/usr/bin/env bash

clock=(
  update_freq=10
  icon=
  icon.padding_left=10
  label.padding_right=10
  script="$PLUGIN_DIR/clock.sh"
)

clock_bracket=(
  background.color=0xff79A6CB
  background.corner_radius=5
  background.border_color=0xffffffff
  background.border_width=2
  background.height=25
)

sketchybar --add item padding_clock right            \
           --set padding_clock "${padding[@]}"       \
           --add item clock right                    \
           --set clock "${clock[@]}"                 \
           --add bracket clock_bracket clock         \
           --set clock_bracket "${clock_bracket[@]}"
