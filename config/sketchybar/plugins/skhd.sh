#!/usr/bin/env bash

args=()

case "$MODE" in
  "focus")
    args+=(--set skhd label="" label.align=center label.drawing=on)
    ;;
  "warp")
    args+=(--set skhd label="ﴯ" label.align=center label.drawing=on)
    ;;
  "resize")
    args+=(--set skhd label="" label.align=center label.drawing=on)
    ;;
  "prefix")
    args+=(--set skhd label="" label.align=center label.drawing=on)
    ;;
  *)
    args+=(--set skhd label="" label.align=center label.drawing=on)
    ;;
esac

sketchybar -m "${args[@]}"
