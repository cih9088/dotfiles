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
            echo ":exclamation:"
            echo "---"
            echo "Focus mode"
        elif [[ $skhd_mode == 'WARP' ]]; then
            echo ":collision:"
            echo "---"
            echo "Warp mode"
        elif [[ $skhd_mode == 'RESIZE' ]]; then
            echo ":point_right:"
            echo "---"
            echo "Resize mode"
        elif [[ $skhd_mode == 'PREFIX' ]]; then
            echo ":sunglasses:"
            echo "---"
            echo "Prefix mode"
        fi
    else
        echo ":relieved:"
        echo "---"
        echo "Normal mode"
    fi
fi
