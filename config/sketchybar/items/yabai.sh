#!/usr/bin/env bash

yabai=(
  icon.width=0
  label.width=20
  label.padding_left=10
  label.padding_right=10
  label.font.size="15.0"
  background.drawing=off
  background.color=0xffadc6db
  background.corner_radius=5
  background.height=18
  script="$PLUGIN_DIR/yabai.sh"
  associated_display=active
)

yabai_bracket=(
  background.color=0xff79A6CB
  background.border_color=0xffffffff
  background.border_width=2
  background.corner_radius=5
  background.height=25
  associated_display=active
)

sketchybar --add event layout_change                     \
           --add event window_focused                    \
           --add event yabai_init                        \
           --add item padding_yabai left                 \
           --set padding_yabai "${padding[@]}"           \
                               associated_display=active \
           --add item yabai left                         \
           --set yabai "${yabai[@]}"                     \
           --subscribe yabai yabai_init                  \
                             window_focused              \
                             mouse.clicked               \
                             mouse.entered               \
                             mouse.exited                \
           --add bracket yabai_bracket yabai             \
           --set yabai_bracket "${yabai_bracket[@]}"

sketchybar --trigger yabai_init
