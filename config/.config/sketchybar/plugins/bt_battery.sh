#!/bin/sh

# Get battery level for Nothing Headphones using helper
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERCENTAGE="$("$SCRIPT_DIR/bt_battery_helper" "Nothing Headphone" 2>/dev/null)"

# Check if headphones are connected and have battery info
if [ "$PERCENTAGE" = "" ] || [ "$PERCENTAGE" = "0" ]; then
  # Headphones not connected or no battery info, don't show anything
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
