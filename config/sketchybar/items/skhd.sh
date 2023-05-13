#!/usr/bin/env bash

skhd=(
  icon.width=0
  label.width=30
  label.padding_left=10
  label.padding_right=10
  label.font.size="15.0"
  background.color=0xffB16286
  background.border_color=0xffffffff
  background.border_width=2
  background.corner_radius=5
  background.height=25
  script="$PLUGIN_DIR/skhd.sh"
)

sketchybar --add event skhd_mode_change      \
           --add item skhd left              \
           --set skhd "${skhd[@]}"           \
           --subscribe skhd skhd_mode_change
