---
name: build-gitbutler
description: >
  Build GitButler desktop app locally for testing. Use when user says "build gitbutler",
  "build nightly", "build release", "build the app", "make a local build", or similar.
  Produces a .app bundle you can run directly on macOS.
---

# Build GitButler Desktop (Nightly) Locally

The nightly tauri config has a placeholder `externalBin` that must be patched before building.
The release.sh script does this automatically, but for local builds we do it manually.

## Steps

### 1. Patch the nightly config

The nightly config at `crates/gitbutler-tauri/tauri.conf.nightly.json` has `"externalBin": ["to be replaced by 'release.sh'"]`. Create a patched copy with real binary names and version `0.0.0` (must be exactly `0.0.0` to suppress the auto-updater prompt):

```bash
cd /Users/danielsusman/gitbutler
cat crates/gitbutler-tauri/tauri.conf.nightly.json \
  | jq '.version = "0.0.0" | .bundle.externalBin = ["gitbutler-git-askpass", "gitbutler-git-setsid"]' \
  > /tmp/tauri.conf.nightly-local.json
```

### 2. Build with tauri

```bash
cd /Users/danielsusman/gitbutler
pnpm tauri build --features "devtools builtin-but irc" --config /tmp/tauri.conf.nightly-local.json 2>&1 &
BUILD_PID=$!

# Wait for the .app bundle to appear (the build is done when Bundling finishes)
APP_PATH="target/tauri/release/bundle/macos/GitButler Nightly.app/Contents"
while [ ! -d "$APP_PATH" ] || [ "$(find "$APP_PATH" -name 'gitbutler-tauri' -newer /tmp/tauri.conf.nightly-local.json 2>/dev/null)" = "" ]; do
  sleep 5
done
# Give it a moment to finish writing
sleep 3
kill $BUILD_PID 2>/dev/null || true
wait $BUILD_PID 2>/dev/null || true
```

**Features explained:**
- `devtools` — enables browser devtools in the release build
- `builtin-but` — embeds the `but` CLI binary into the app
- `irc` — enables IRC collaboration (enabled for nightly/dev, not release)

This will take several minutes (frontend build + full Rust release compile).
The build is backgrounded and we poll for the `.app` bundle to appear. The DMG
bundling step runs after and can be safely killed — it's not needed for local testing.

### 3. Output location & launch

The built app lands at:
```
target/tauri/release/bundle/macos/GitButler Nightly.app
```

To install and run, codesign and replace the copy in `/Applications`:

```bash
osascript -e 'quit app "GitButler Nightly"' 2>/dev/null; sleep 1

# Codesign with local dev identity so macOS Keychain remembers "Always Allow"
# across rebuilds (unsigned builds get a new hash each time → repeated prompts).
codesign --force --deep --sign "$CODESIGN_IDENTITY" \
  "target/tauri/release/bundle/macos/GitButler Nightly.app"

rm -rf "/Applications/GitButler Nightly.app"
cp -R "target/tauri/release/bundle/macos/GitButler Nightly.app" "/Applications/GitButler Nightly.app"
open "/Applications/GitButler Nightly.app"
```

**Important:** macOS will prefer the `/Applications` copy over the build directory one,
so always copy there before launching. Otherwise you may run a stale version.

## Notes

- The build uses `target/tauri/` (not `target/release/`) because tauri manages its own build directory.
- On macOS, `externalBin` needs both `gitbutler-git-askpass` and `gitbutler-git-setsid` (setsid is a dummy kept for backward compat with installers ≤0.19.3).
- The `beforeBuildCommand` in the tauri config handles building the git helper binaries automatically via `tauri-before-build-command.sh`.
- Local builds are codesigned with your Apple Development identity so Keychain "Always Allow" persists across rebuilds.
- After installing a fresh nightly build, UI settings (theme, diff font, editor, etc.) may need syncing from the main GitButler app. See the **gitbutler-settings** skill for how to copy settings between main and nightly builds.
