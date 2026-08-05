#!/bin/bash
[ -n "$TMUX" ] || exit 0
[ -z "$CLAUDE_TMUX_RENAME" ] || exit 0

input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
[ -n "$session_id" ] || exit 0

cache="${TMPDIR:-/tmp}/claude-tmux-rename/$session_id"

if [ ! -s "$cache" ]; then
  [ -s "$transcript" ] || exit 0
  prompt=$(jq -rn '
    first(
      inputs
      | select(.type == "user" and .isMeta != true)
      | .message.content
      | if type == "string" then . else (map(select(.type == "text") | .text) | join(" ")) end
    ) // empty' "$transcript" | cut -c1-500)
  [ -n "$prompt" ] || exit 0
  title=$(CLAUDE_TMUX_RENAME=1 env -u ANTHROPIC_API_KEY claude -p --model haiku \
    --settings '{"hooks":{}}' \
    "Reply with only a 3-5 word lowercase tmux window title summarizing this coding session's opening request: $prompt" \
    </dev/null 2>/dev/null | sed -n 1p)
  [ -n "$title" ] || exit 0
  mkdir -p "$(dirname "$cache")"
  printf '%s\n' "$title" >"$cache"
fi

name=$(sed -n 1p "$cache")
[ -n "$name" ] && tmux rename-window -t "${TMUX_PANE:?}" "$name"
