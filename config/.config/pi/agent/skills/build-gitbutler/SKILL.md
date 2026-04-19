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

The nightly config at `crates/gitbutler-tauri/tauri.conf.nightly.json` has `"externalBin": ["to be replaced by 'release.sh'"]`. Create a patched copy with real binary names and a dev version:

```bash
cd /Users/danielsusman/gitbutler
cat crates/gitbutler-tauri/tauri.conf.nightly.json \
  | jq '.version = "0.0.0-dev" | .bundle.externalBin = ["gitbutler-git-askpass", "gitbutler-git-setsid"]' \
  > /tmp/tauri.conf.nightly-local.json
```

### 2. Build with tauri

```bash
cd /Users/danielsusman/gitbutler
pnpm tauri build --features "devtools builtin-but irc" --config /tmp/tauri.conf.nightly-local.json
```

**Features explained:**
- `devtools` — enables browser devtools in the release build
- `builtin-but` — embeds the `but` CLI binary into the app
- `irc` — enables IRC collaboration (enabled for nightly/dev, not release)

This will take several minutes (frontend build + full Rust release compile).

### 3. Output location

The built app lands at:
```
target/tauri/release/bundle/macos/GitButler Nightly.app
```

DMG installer (if needed):
```
target/tauri/release/bundle/macos/GitButler Nightly_<version>_aarch64.dmg
```

To run directly: `open "target/tauri/release/bundle/macos/GitButler Nightly.app"`

## Notes

- The build uses `target/tauri/` (not `target/release/`) because tauri manages its own build directory.
- On macOS, `externalBin` needs both `gitbutler-git-askpass` and `gitbutler-git-setsid` (setsid is a dummy kept for backward compat with installers ≤0.19.3).
- The `beforeBuildCommand` in the tauri config handles building the git helper binaries automatically via `tauri-before-build-command.sh`.
- No code signing is done for local builds.
- After installing a fresh nightly build, UI settings (theme, diff font, editor, etc.) may need syncing from the main GitButler app. See the **gitbutler-settings** skill for how to copy settings between main and nightly builds.
