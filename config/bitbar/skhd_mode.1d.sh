#!/bin/bash

export PATH=/usr/local/bin:$PATH

# skhd saves the current keyboard mode to this file
modefile=$TMPDIR/current_skhd_mode
if [[ -r $modefile ]]; then
    mod="$(cat "$modefile")"
    mod="$(echo "$mod" | awk '{print toupper($0)}')"
    if [[ -n $mod ]]; then
        skhd_mode="$mod"
        if [[ $skhd_mode == 'FOCUS' ]]; then
            echo "✾ | size=20"
            echo "---"
            echo "Focus mode"
        elif [[ $skhd_mode == 'WARP' ]]; then
            echo "✂ | size=20"
            echo "W"
            echo "---"
            echo "Warp mode"
        elif [[ $skhd_mode == 'RESIZE' ]]; then
            echo "♻ | size=15"
            echo "---"
            echo "Resize mode"
        elif [[ $skhd_mode == 'PREFIX' ]]; then
            echo "⚑ | size=20"
            echo "---"
            echo "Prefix mode"
        fi
    else
        echo "✌ | size=20"
        echo "---"
        echo "Normal mode"
    fi
fi
