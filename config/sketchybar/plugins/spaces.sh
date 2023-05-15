#!/usr/bin/env bash

update() {
  sketchybar --set $NAME icon.highlight=$SELECTED     \
                         label.highlight=$SELECTED    \
                         background.drawing=$SELECTED
}

mouse_clicked() {
  case "$NAME" in
    "separator" )
      yabai -m space --create && sketchybar --trigger space_change
      ;;
    * )
      if [ "$BUTTON" = "right" ]; then
        yabai -m space --destroy $SID
        sketchybar --trigger windows_on_spaces --trigger space_change
      else
        yabai -m space --focus $SID 2>/dev/null
      fi
      ;;
  esac
}

mouse_entered() {
  sketchybar --set $NAME background.drawing=on
}

mouse_exited() {
  sketchybar --set $NAME background.drawing=off
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
