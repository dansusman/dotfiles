---
name: gitbutler-settings
description: Sync or update GitButler app settings between main and nightly builds. Use when asked to copy settings, fix theme, sync preferences, or troubleshoot differences between GitButler and GitButler Nightly.
---

# GitButler Settings Sync

## Settings Locations

### App config (projects, forge/GitHub auth)
- Main: `~/Library/Application Support/com.gitbutler.app/`
- Nightly: `~/Library/Application Support/com.gitbutler.app.dev/`
- Files: `projects.json`, `forge_settings.json`, `.window-state.json`
- These are plain JSON, can be directly copied with `cp`.

### UI settings (theme, diff font, editor, terminal, etc.)
Stored in WebKit localStorage SQLite databases:

- Main: `~/Library/WebKit/com.gitbutler.app/WebsiteData/Default/khRdkn4CWpOpPlHOmRfKyMbetCmTCyBR-gp1z4KVDTQ/khRdkn4CWpOpPlHOmRfKyMbetCmTCyBR-gp1z4KVDTQ/LocalStorage/localstorage.sqlite3`
- Nightly: `~/Library/WebKit/com.gitbutler.app.nightly/WebsiteData/Default/09RptiadMpCa4E35TC-j1E2Zee9HmcE6IlDkoKUhMSE/09RptiadMpCa4E35TC-j1E2Zee9HmcE6IlDkoKUhMSE/LocalStorage/localstorage.sqlite3`

**Important:** The hash directories in the paths above may change if WebKit regenerates them. If the paths don't exist, use `find ~/Library/WebKit/com.gitbutler.app* -name "localstorage.sqlite3"` to discover them.

The key `settings-json` in the `ItemTable` table holds all UI preferences as a **UTF-16LE encoded blob**. This includes: theme (light/dark), diff font, ligatures, editor, terminal, zoom, tab size, etc.

## How to Copy UI Settings

```bash
# 1. Get the hex blob from main
MAIN_DB="<path to main localstorage.sqlite3>"
NIGHTLY_DB="<path to nightly localstorage.sqlite3>"

HEX=$(sqlite3 "$MAIN_DB" "SELECT hex(value) FROM ItemTable WHERE key = 'settings-json';")

# 2. Insert into nightly
sqlite3 "$NIGHTLY_DB" "INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('settings-json', x'$HEX');"
```

## How to Read Settings

```bash
sqlite3 "$DB" "SELECT hex(value) FROM ItemTable WHERE key = 'settings-json';" | python3 -c "
import sys, json
h = sys.stdin.read().strip()
b = bytes.fromhex(h)
print(json.dumps(json.loads(b.decode('utf-16-le')), indent=2))
"
```

## Notes
- Quit GitButler/Nightly before modifying their SQLite databases.
- Restart the app after changes for them to take effect.
- To list all localStorage keys: `sqlite3 "$DB" "SELECT key FROM ItemTable;"`
