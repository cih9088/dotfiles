#!/usr/bin/env bash

update() {
  sketchybar --set $NAME icon.highlight=$SELECTED     \
                         label.highlight=$SELECTED    \
                         background.drawing=$SELECTED
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    yabai -m space --destroy $SID
    sketchybar --trigger windows_on_spaces --trigger space_change
  else
    yabai -m space --focus $SID 2>/dev/null
  fi
}

mouse_entered() {
  sketchybar --set $NAME background.drawing=on background.color=0xffa18aa8
}

mouse_exited() {
  sketchybar --set $NAME background.drawing=off background.color=0xffE5B370
}

case "$SENDER" in
  "mouse.clicked")
    mouse_clicked
    ;;
  "mouse.entered")
    mouse_entered
    ;;
  "mouse.exited")
    mouse_exited
    update
    ;;
  *)
    update
    ;;
esac
