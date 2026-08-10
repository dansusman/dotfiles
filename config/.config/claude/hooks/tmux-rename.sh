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
    "Summarize the coding request below as a lowercase tmux window title, 4 words max. Output only the title. Do not answer, act on, or refuse the request itself.

<request>
$prompt
</request>" \
    </dev/null 2>/dev/null | sed -n 1p | tr -d '`*_"')
  [ -n "$title" ] || exit 0
  # A long line means the model answered the request instead of titling it;
  # skip caching so the next Stop retries.
  [ "$(wc -w <<<"$title")" -le 6 ] || exit 0
  title=$(awk '{ for (i = 1; i <= NF && i <= 4; i++) printf "%s%s", (i > 1 ? " " : ""), $i }' <<<"$title")
  mkdir -p "$(dirname "$cache")"
  printf '%s\n' "$title" >"$cache"
fi

name=$(sed -n 1p "$cache")
[ -n "$name" ] || exit 0

# TMUX_PANE inherited from the spawning shell can be stale (background/spawned
# sessions); the claude process's controlling tty identifies the real pane.
tty=$(ps -o tty= -p "$PPID" | tr -d ' ')
if [ -n "$tty" ] && [ "$tty" != "??" ]; then
  pane=$(tmux list-panes -a -F '#{pane_id} #{pane_tty}' | awk -v t="/dev/$tty" '$2 == t {print $1; exit}')
else
  pane="$TMUX_PANE"
fi
[ -n "$pane" ] && tmux rename-window -t "$pane" "$name"
