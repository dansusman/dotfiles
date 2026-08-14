#!/usr/bin/env sh

# The count is written by the `gh-notis watch` agent, which is the only thing
# polling GitHub. Reading it here keeps the bar free of API calls.
COUNT_FILE="$HOME/.local/state/gh-notis/count"

# U+F09B, the Font Awesome GitHub mark in Hack Nerd Font. Spelled as bytes
# because editors and shells strip a pasted private-use glyph.
GH_MARK=$(printf '\357\202\233')
COLOR_UNREAD=0xffffffff
COLOR_CLEAR=0xff6e6e6e

count=$(cat "$COUNT_FILE" 2>/dev/null)
case $count in
  ''|*[!0-9]*) count=0;;
esac

# The API caps a notifications page at 50, so 50 means "at least 50".
if [ "$count" -ge 50 ]; then
  count="50+"
fi

if [ "$count" = "0" ]; then
  sketchybar --set "$NAME" icon="$GH_MARK" icon.color=$COLOR_CLEAR label="" label.drawing=off
else
  sketchybar --set "$NAME" icon="$GH_MARK" icon.color=$COLOR_UNREAD \
    label="$count" label.drawing=on
fi
