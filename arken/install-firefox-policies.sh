#!/usr/bin/env bash
# Symlink the committed policies.json into each installed Firefox's distribution
# directory, where Firefox reads enterprise policies on startup. Symlink (not
# copy) so editing the dotfile takes effect after a restart with no reinstall.
# Firefox patches in place on auto-update so this survives updates; a full
# reinstall wipes the app bundle, so re-run this after reinstalling Firefox.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/policies.json"
[ -f "$src" ] || { echo "missing $src — run ./gen-firefox-policies.sh first" >&2; exit 1; }

# Dev Edition is the daily driver; pass --all to also link stock Firefox.
apps=("/Applications/Firefox Developer Edition.app")
[ "${1:-}" = "--all" ] && apps+=("/Applications/Firefox.app")

for app in "${apps[@]}"; do
  [ -d "$app" ] || continue
  dist="$app/Contents/Resources/distribution"
  mkdir -p "$dist"
  ln -sf "$src" "$dist/policies.json"
  echo "linked -> $dist/policies.json"
done

echo "Restart Firefox, then check about:policies to confirm Cookies.Allow loaded."
