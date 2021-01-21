#!/bin/bash

export PATH=/opt/homebrew/bin/:/usr/local/bin:$PATH


# Functions to call by argument
case $1 in
  "layout" )
    yabai -m space --layout "$2"
    exit 0
  ;;

  "split" )
    yabai -m window --toggle split
    exit 0
  ;;

  "balance" )
    yabai -m space --balance
    exit 0
  ;;

  "stop" )
    brew services stop yabai
    brew services stop skhd
    exit 0
  ;;

  "restart" )
    brew services restart yabai
    brew services restart skhd
    exit 0
  ;;

  "quicklook" )
    qlmanage -p "$2" > /dev/null 2>&1
    exit 0
  ;;

esac



menu=
skhd_mode=

# skhd saves the current keyboard mode to this file
modefile=$TMPDIR/current_skhd_mode
if [[ -r $modefile ]]; then
    mod="$(cat "$modefile")"
    mod="$(echo "$mod" | awk '{print toupper($0)}')"
    if [[ -n $mod ]]; then
        skhd_mode="$mod"
        if [[ $skhd_mode == 'FOCUS' ]]; then
            menu+="✧"
            shkd_mode="Focus mode"
        elif [[ $skhd_mode == 'WARP' ]]; then
            menu+="⎌"
            skhd_mode="Warp mode"
        elif [[ $skhd_mode == 'RESIZE' ]]; then
            menu+="✠"
            skhd_mode="Resize mode"
        elif [[ $skhd_mode == 'PREFIX' ]]; then
            menu+="⚑"
            skhd_mode="Prefix mode"
        fi
    else
        menu+="✌"
        skhd_mode="Normal mode"
    fi
else
    menu+="⚠"
    skhd_mode="-"
fi

menu+="  "


# Is the server running
yabai -m query --spaces > /dev/null 2>&1
state=$?

if [ $state != 0 ] ; then
  menu+="⚠"
else
  mode=$(yabai -m query --spaces --space | grep -o -E "float|bsp")
  case $mode in
    "bsp" )
      menu+="⑉"
      ;;
    "float" )
      menu+="⑇"
      ;;
    *)
      ;;
  esac
fi


menu+="|size=20"

echo $menu
echo "---"
echo $skhd_mode
if [ $(yabai -m query --windows --window | jq '.floating') -eq 1 ]; then
    echo "Floating window"
else
    echo "BSP window"
fi
echo "---"
echo "BSP | bash='$0' param1=layout param2=bsp terminal=false refresh=true"
echo "Float | bash='$0' param1=layout param2=float terminal=false refresh=true"
echo "---"
echo "Change Split | bash='$0' param1=split terminal=false refresh=true"
echo "Same Split Ratio | bash='$0' param1=balance terminal=false refresh=true"
echo "---"
if [ $state != 0 ] ; then
  echo "Stopped | color='red'"
else
  echo "Started | color='green'"
fi
echo "--Restart | bash='$0' param1=restart terminal=false refresh=true"
echo "--Stop | bash='$0' param1=stop terminal=false refresh=true"
echo "View Bindings | bash='$0' param1=quicklook param2='$HOME/.config/skhd/skhdrc' terminal=false"
