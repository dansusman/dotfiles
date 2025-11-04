#!/bin/sh

# Get battery level for Nothing Headphones
BT_INFO="$(system_profiler SPBluetoothDataType 2>/dev/null | grep -A 5 "Nothing Headphone")"
PERCENTAGE="$(echo "$BT_INFO" | grep "Battery Level" | sed 's/.*Battery Level: \([0-9]*\)%.*/\1/')"

# Check if headphones are connected
if [ "$PERCENTAGE" = "" ]; then
  # Headphones not connected, don't show anything
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# Select icon based on battery level
case "${PERCENTAGE}" in
  [8-9][0-9]|100) ICON="󰥈"  # Full battery
  ;;
  [6-7][0-9]) ICON="󰥆"      # High battery
  ;;
  [4-5][0-9]) ICON="󰥄"      # Medium battery
  ;;
  [2-3][0-9]) ICON="󰥃"      # Low battery
  ;;
  *) ICON="󰥁"              # Very low battery
esac

# Update the sketchybar item
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" drawing=on
