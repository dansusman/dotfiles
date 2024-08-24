#!/usr/bin/env bash

CITY="$(curl -s ipinfo.io/city)"
status=$(curl -s "wttr.in/${CITY}?u&format=%t")
temp=$(echo $status | awk -F '|' '{print $1}')
temp="${temp//\+/}"
temp="${temp// /}"

icon=

sketchybar -m --set weather icon="$icon" \
              --set weather label="$temp"
