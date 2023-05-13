#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

data=$(yabai -m query --windows --window)

window_title=$(echo $data | jq -r '.title')
app=$(echo $data | jq -r '.app')

[ "${#window_title}" -gt 40 ] && window_title="$(echo $window_title | head -c 40)…"

sketchybar --set $NAME icon="$app" label="| $window_title"
