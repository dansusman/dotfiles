#!/usr/bin/env bash
# Export Firefox per-site cookie "Allow" exceptions (permissions.sqlite, which
# is binary and per-profile) into a declarative policies.json that can live in
# dotfiles. The Cookies.Allow array re-applies the same per-origin cookie
# permission on startup, so a fresh profile inherits years of accumulated
# opt-outs without hand-clicking through Manage Exceptions.
#
# Usage: ./gen-firefox-policies.sh [profile-dir] > policies.json
# Defaults to the dev-edition profile.
set -euo pipefail

profile="${1:-$HOME/Library/Application Support/Firefox/Profiles/9hhly564.dev-edition-default}"
db="$profile/permissions.sqlite"
[ -f "$db" ] || { echo "no permissions.sqlite at $db" >&2; exit 1; }

# permission 1 = Allow, 8 = Allow-for-session. Read immutable so a running
# Firefox holding the lock doesn't block the export.
origins=$(sqlite3 "file:$db?immutable=1" \
  "SELECT origin FROM moz_perms WHERE type LIKE 'cookie%' AND permission IN (1,8) ORDER BY origin;")

json_array=$(printf '%s\n' "$origins" | sed '/^$/d' | \
  awk '{ printf "%s    %s\"%s\"", (NR>1?",\n":""), "", $0 }')

cat <<EOF
{
  "policies": {
    "Cookies": {
      "Allow": [
$json_array
      ]
    }
  }
}
EOF
