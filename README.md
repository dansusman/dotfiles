# dotfiles
All my config files for macOS.

## Tour
- `arken`: Firefox Hardening via [arkenfox/user.js](https://github.com/arkenfox/user.js)
- `chrome`: Currently unused, but Firefox UI tweaking
- `config/.config`: anything that expects to land in `~/.config`
    - `karabiner`: configs for [Karabiner Elements](https://github.com/pqrs-org/Karabiner-Elements) with sublayering via [mxstbr](https://github.com/mxstbr/karabiner)
    - `nvim`: one-file, newest, Lua-only, simple dev setup via [`kickstart.nvim`](https://github.com/nvim-lua/kickstart.nvim)
    - `sketchybar`: i3-inspired bottom bar for macOS via [sketchybar](https://github.com/FelixKratz/SketchyBar)
    - `skhd`: keybinds for controlling yabai windows via [skhd](https://github.com/koekeishiya/skhd)
    - `yabai`: tiling window manager via [yabai](https://github.com/koekeishiya/yabai)
- `defaults`: macOS specific settings (noTunes config, wifi toggle script, etc.)
- `git`: Default git message, global git ignore, etc.
- `gitmux`: tmux statusline git status config
- `tmux`: tmux configuration
- `wezterm`: wezterm terminal emulator settings
- `xcode`: Xcode keybinds, theme, and cheatsheet
- `zsh`: Shell aliases, theming, utils, etc.

> [!WARNING]
> The following folders are quite outdated.
- `nvim-old`: awful, old, vimscript-based dev setup using Plug package manager. Don't look, don't use.
- `init.el`: Emacs stuff, not great, somewhat out of date probably.
- `nvim1`: slightly better, Lua-only dev setup using Packer package manager. Don't look, don't use.

## Installation Steps
1. Clone this repo into home directory
2. Install [homebrew](https://brew.sh/) via `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. Navigate into the clone and run `./brew/install` to install most of the brew packages I care about.
4. Run `./install` to move config files to HOME_DIR.
5. Open nvim and plugins will start installing
6. Close nvim once the plugins are installed
7. Reopen nvim and let LSPs install
8. Install the few apps listed in [Current Favorite Tools](#current-favorite-tools) that are labeled "not included in brew install script"
9. Run `ln -s ~/.dotfiles/susman.zsh-theme ~/.oh-my-zsh/themes` to grab my custom OhMyZSH theme
10. Run `ln -s ~/.dotfiles/git/.gitignore ~/.gitignore && git config --global core.excludesfile ~/.gitignore` to setup worktrees flow

### nvim as XCode replacement
1. Ensure `sourcekit-lsp` and `xcodebuild.nvim` are installed in your nvim setup. Ensure `xcode-build-server` is on your machine (should've been installed in brew install script).
2. Navigate to the root directory of your XCode project/workspace.
3. Run `xcode-build-server config -scheme <XXX> -workspace *.xcworkspace`, where `<XXX>` is the target you plan to build/run. You can be more specific than `*.xcworkspace` if you'd like.
4. Reopen nvim and LSP/BSP should be working, `<leader>xr` should build and run your project

## Current Favorite Tools

Here's a running list of things I enjoy using right now. A lot of them are macOS specific, but some are platform agnostic.

### Open Source ✅
- [Karabiner Elements](https://github.com/pqrs-org/Karabiner-Elements): Remap Fn to Hyper, Ctrl+P/Ctrl+n to Arrow Up/Down, mnemonic sublayering for media control, movement, opening browser links, opening applications, etc.
- [yabai](https://github.com/koekeishiya/yabai): Tiling window manager
- [skhd](https://github.com/koekeishiya/skhd): Configurable keyboard shortcuts (used to control yabai with the keyboard)
- [borders](https://github.com/FelixKratz/JankyBorders): Borders around windows, colored differently when resizing windows via yabai
- [gitu](https://github.com/altsem/gitu) - TUI git client inspired by Magit
- [Maccy](https://github.com/p0deje/Maccy): Clipboard manager
- [Gifski](https://github.com/sindresorhus/Gifski): Video to Gif converter
- [Lunar](https://github.com/alin23/Lunar): Display brightness controller
- [noTunes](https://github.com/tombonez/noTunes): Prevent Apple Music from launching
- [BreakTimer](https://github.com/tom-james-watson/breaktimer-app): Reminder to take an eye break every hour
- [zoxide](https://github.com/ajeetdsouza/zoxide): Smarter `cd`
- [ripgrep](https://github.com/BurntSushi/eipgrep): More powerful `grep`
- [Firefox Dev Edition](https://www.mozilla.org/en-US/firefox/developer/): Hopefully self explanatory at this point, source code [here](https://hg.mozilla.org/mozilla-central/)
- [Omnivore](https://github.com/omnivore-app/omnivore) - read-it-later list of links (NOT INCLUDED IN BREW INSTALL SCRIPT)
- [TinkerTool](https://www.bresink.com/osx/0TinkerTool/download.php) - Sane macOS defaults, set them once and never open the app again. (NOT INCLUDED IN BREW INSTALL SCRIPT)

### Proprietary ❌
- [Cleanshot X](https://cleanshot.com/): Better screenshotting
- [Choosy Browser](https://choosy.app/): Send certain links to certain browsers
- [1Password](https://1password.com/): Password manager
- [homerow](https://homerow.app): Navigate anywhere with the keyboard

