#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

if [ "$SELECTED" = "true" ]; then
  sketchybar -m --set $NAME icon.highlight=on background.drawing=on background.border_width=1
else
  sketchybar -m --set $NAME icon.highlight=off background.drawing=off background.border_width=0
fi
