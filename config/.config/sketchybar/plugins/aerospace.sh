#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar -m --set $NAME icon.highlight=on background.drawing=on background.border_width=1
else
    sketchybar -m --set $NAME icon.highlight=off background.drawing=off background.border_width=0
fi
