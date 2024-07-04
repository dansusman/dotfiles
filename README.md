# dotfiles
All my config files for macOS.

## Tour
- `.config`: skhd, yabai, Karabiner Elements, etc. configurations
- `arken`: Firefox Hardening via [arkenfox/user.js](https://github.com/arkenfox/user.js)
- `chrome`: Currently unused, but Firefox UI tweaking
- `nvim`: one-file, newest, Lua-only, simple dev setup via [`kickstart.nvim`](https://github.com/nvim-lua/kickstart.nvim)
- `sketchybar`: i3-inspired bottom bar for macOS via [sketchybar](https://github.com/FelixKratz/SketchyBar)
- `tmux`: tmux configuration
- `zsh`: Shell aliases, theming, utils, etc.

> :warning: The following folders are quite outdated.
- `nvim-old`: awful, old, vimscript-based dev setup using Plug package manager. Don't look, don't use.
- `init.el`: Emacs stuff, not great, somewhat out of date probably.
- `nvim1`: slightly better, Lua-only dev setup using Packer package manager. Don't look, don't use.

## Installation Steps
1. Clone this repo into home directory
2. Navigate into the clone and run `./brew/install`
3. Make symlinks from any directory in this repo to your home directory (see a couple examples below). TODO: make an install script for this.
4. Run `mkdir ~/.config/nvim`
5. Run `ln -s ~/dotfiles/nvim ~/.config/nvim`
6. Open nvim and plugins will start installing
7. Close nvim once the plugins are installed
8. Reopen nvim and let LSPs install
9. Install the few apps listed in [Current Favorite Tools](#current-favorite-tools) that are labeled "not included in brew install script"

### Accessing Susman Oh My Zsh Theme
`ln -s ~/.dotfiles/zsh/susman.zsh-theme ~/.oh-my-zsh/themes`

### Setting up Zsh in General
`stow ~/.dotfiles/zsh`

### Set up Git Worktrees
`ln -s ~/.dotfiles/git/.gitignore ~/.gitignore`
`git config --global core.excludesfile ~/.gitignore`

### Setting up Sketchybar config
`ln -s ~/.dotfiles/sketchybar ~/.config/sketchybar`

### Bonus Tip for Futureself
If you want add symbolic links to nested folders at nested folder paths, like the following user story, follow this guide.

User X wants to add some `skhd` configuration in the directory `.dotfiles/skhd` and stow it in `~/.config/skhd`. X makes 
a new directory in their clone of this repo, `skhd`, adds their `.skhdrc` file in there, and creates the symlink using:
`stow -t ~/.config ~/.dotfiles/config`. This accounts for nesting so the file structure will match in `~/.config`.

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

## TODO
1. Update install script. It might stow things correctly but I haven't tested on a new machine in years.
