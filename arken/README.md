## Arkenfox user.js Firefox Hardening

Follow the guide at https://github.com/arkenfox/user.js for installation/updating.

It essentially boils down to the following steps, though.

### Steps

1. Clone the arkenfox/user.js repo
2. Open Firefox, navigate to `about:support`
3. Copy the path to current profile directory
4. Quit Firefox
5. Backup current profile (https://github.com/arkenfox/user.js/wiki/2.2-Backup)
6. Copy `user.js`, `updater.sh`, `prefsCleaner.sh` from your arkenfox/user.js clone to the root directory of your Firefox profile
7. Copy `user-overrides.js` from your dansusman/dotfiles clone
8. Run `updater.sh` then `prefsCleaner.sh` in your Firefox profile root dir
9. Open Firefox, navigate to `about:config`
10. Search `_user.js.parrot`, if you see something like `SUCCESS: No no he's not dead, he's, he's restin'!`, your installation was successful
11. Search `full-screen-api.macos-native-full-screen` and set to `false` (disable macOS fullscreening so spaces work better)

## Cookie exceptions (clear-on-shutdown opt-outs)

Arkenfox clears cookies + site storage on every shutdown. Per-site "Allow"
exceptions (Manage Exceptions in the UI) live in the profile's binary
`permissions.sqlite`, not in any pref file, so they don't survive a fresh
profile. These two scripts capture and re-apply them declaratively via Firefox
enterprise policies:

1. `./gen-firefox-policies.sh > policies.json` — export current cookie "Allow"
   exceptions from the live profile into `policies.json`. Re-run and commit
   whenever you add exceptions in the UI.
2. `./install-firefox-policies.sh` — symlink `policies.json` into Firefox Dev
   Edition's `distribution/` dir (the daily driver). Pass `--all` to also link
   stock Firefox. Restart Firefox; verify at `about:policies`.

## Extensions
1. Firefox Multi-Account Container
2. 1Password
3. DarkReader
4. UBlock Origin
5. 600% Sound Volume
6. Video Playback Speed Controller (see vpsc.txt in this folder for custom keymaps)
7. Vimium C (see vimium.txt in this folder for custom keymaps)
8. Switch To Previous Active Tab (opt+1, opt+2, etc. to ignore pinned tabs)
9. Omnivore
10. BetterTTV
11. Consent-O-Matic

