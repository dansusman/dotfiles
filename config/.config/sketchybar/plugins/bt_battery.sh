#!/bin/sh

# Get battery level for Nothing Headphones using helper
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERCENTAGE="$("$SCRIPT_DIR/bt_battery_helper" "Nothing Headphone" 2>/dev/null)"
STATUS=$?

# Exit 2: connected but macOS isn't reporting battery, show unknown marker
if [ "$STATUS" = "2" ]; then
  sketchybar --set "$NAME" icon="󰋋" label="?" drawing=on
  exit 0
fi

# Any other non-success means not connected, don't show anything
if [ "$STATUS" != "0" ] || [ "$PERCENTAGE" = "" ]; then
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
