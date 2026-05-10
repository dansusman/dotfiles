#!/bin/bash
# UserPromptSubmit hook: render newly-attached images inline via kitty graphics protocol.
# Works in terminals supporting kitty graphics: Kitty, Ghostty, WezTerm.

set -e

input=$(cat)
session_id=$(printf '%s' "$input" | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin).get("session_id",""))' 2>/dev/null)

[ -z "$session_id" ] && exit 0

cache_dir="$HOME/.claude/image-cache/$session_id"
[ -d "$cache_dir" ] || exit 0

state_dir="$HOME/.claude/cache/image-hook-state"
mkdir -p "$state_dir"
seen_file="$state_dir/$session_id.seen"
touch "$seen_file"

# tty for drawing
tty_dev="/dev/tty"
[ -w "$tty_dev" ] || exit 0

shopt -s nullglob
new_imgs=()
for img in "$cache_dir"/*.png "$cache_dir"/*.jpg "$cache_dir"/*.jpeg; do
  basename=$(basename "$img")
  if ! grep -Fxq "$basename" "$seen_file"; then
    new_imgs+=("$img")
    echo "$basename" >> "$seen_file"
  fi
done

if [ ${#new_imgs[@]} -gt 0 ]; then
  (
    /usr/bin/qlmanage -p "${new_imgs[@]}" >/dev/null 2>&1 &
    sleep 0.3
    /usr/bin/osascript -e 'tell application "System Events" to set frontmost of (first process whose name is "qlmanage") to true' >/dev/null 2>&1 || true
  ) &
  disown
fi

exit 0
