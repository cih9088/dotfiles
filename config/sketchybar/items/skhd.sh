#!/usr/bin/env bash

skhd=(
  icon.width=0
  label.width=20
  label.padding_left=5
  label.padding_right=5
  label.font.size="15.0"
  script="$PLUGIN_DIR/skhd.sh"
)

skhd_bracket=(
  background.color=0xffB16286
  background.border_color=0xffffffff
  background.border_width=2
  background.corner_radius=5
  background.height=25
)

sketchybar --add event skhd_mode_change            \
           --add item padding_skhd left            \
           --set padding_skhd "${padding[@]}"      \
           --add item skhd left                    \
           --set skhd "${skhd[@]}"                 \
           --subscribe skhd skhd_mode_change       \
           --add bracket skhd_bracket skhd         \
           --set skhd_bracket "${skhd_bracket[@]}"
