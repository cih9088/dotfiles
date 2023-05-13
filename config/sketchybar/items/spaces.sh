#!/usr/bin/env bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

sid=0
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    associated_space=$sid
    icon="${SPACE_ICONS[i]}"
    icon.padding_left=7
    icon.padding_right=7
    icon.highlight_color=0xffffffff
    label.drawing=off
    label.font="sketchybar-app-font:Regular:13.0"
    label.padding_right=5
    label.highlight_color=0xffffffff
    label.y_offset=-1
    background.drawing=off
    background.color=0xffE5B370
    background.corner_radius=5
    background.height=18
    script="$PLUGIN_DIR/spaces.sh"
  )

  sketchybar --add space space.$sid left          \
             --set space.$sid "${space[@]}"       \
             --subscribe space.$sid mouse.clicked \
                                    mouse.entered \
                                    mouse.exited
done

spaces_bracket=(
  background.color=0xff8E6F98
  background.border_color=0xffffffff
  background.border_width=2
  background.corner_radius=5
  background.height=26
)

separator=(
  icon=
  icon.font="$FONT:Heavy:12.0"
  icon.y_offset=1
  padding_left=5
  padding_right=5
  label.drawing=off
  associated_display=active
  click_script='yabai -m space --create && sketchybar --trigger space_change'
)

sketchybar --add item separator left                   \
           --set separator "${separator[@]}" \
           --add bracket spaces_bracket '/space\..*/' separator  \
           --set spaces_bracket "${spaces_bracket[@]}" \
